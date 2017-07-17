function modepar = modeparextract(fdata, fpoints, modaltype, auxvar, ptype)
% function to plot frf/singular value and select peaks
%
% Parameter
% - fdata       : frf if ema, singular value if oma
% - fpoints     : frequency points fdata
% - modaltype   : type of modal analysis, 'ema' if EMA, 'oma' if OMA
% - auxvar      : auxillary variable. meancoherence if EMA, singular
%             vectors if OMA
% - ptype       : 0 --> manual selection, 1 auto selection for full svalue
%                 2 --> auto selection for distributed fdd
%
% Output
% modepar --> structure that contains modal parameter related variables:
% - fn          : natural frequencies
% - peakvaldb   : peak value in frf (EMA), or singular value (OMA)
% - mshape      : complex mode shapes of each fn
% - coh         : coherence value in selected fn (only for EMA)
%
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 26/03/2017

% check if oma or ema, oma shouldn't have coherence data
if ~(strcmp(modaltype,'ema') || strcmp(modaltype,'oma'))
    error('Unrecognized type, use ''ema'' or ''oma''');
end 

%create modepar struct to save data
modepar = struct([]);

%frequncy point for modal coherence & mac calculation
nvalid = 10;

%peak selections process type
if (ptype == 2 && strcmp(modaltype,'oma'))
   %smoothing parameter for singular value plot
   filorder = 2;
   fillength = 2*floor(length(fdata)/3/2)+1;

   %apply smoothing
   svalplot = mag2db(abs(fdata));
   svalsmooth = sgolayfilt(svalplot(:,1),filorder,fillength);
   %svalsmooth = svalplot(:,1);
   
   %find the maximum value
   [mag, peakloc] = max(svalsmooth);

   modepar(1).fn = fpoints(peakloc);

   %save peak values in db
   modepar(1).peakvaldb = mag;

   %obtain corresponding index of fn
   peakmarker = peakloc;
   modepar(1).ind_fn = peakloc;

   %save the graph data
   modepar(1).svalsmooth = svalsmooth;

   %plot the graph comparsion
   subplot(2,1,1), plot(fpoints, svalplot);
   xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'),xticks(fpoints(1):20:fpoints(end)) 
   ylabel('Magnitude (db)');
   subplot(2,1,2), plot(fpoints, svalsmooth,'-o','MarkerIndices',peakmarker,...
        'MarkerFaceColor','red'); 
   xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'),xticks(fpoints(1):20:fpoints(end)) 
   ylabel('Magnitude (db)');
   pause;
   close all

elseif (ptype == 1 && strcmp(modaltype,'oma'))
   %auto peak selection
   svalplot = mag2db(abs(fdata));
   [peakloc, mag] = peakpicker(svalplot(:,1),0.3);
   

    for i=1:length(peakloc)
            %save natural frequency
            modepar(i).fn = fpoints(peakloc(i));

            %save peak values in db
            modepar(i).peakvaldb = mag(i);

            %obtain corresponding index of fn
            peakmarker(i) = peakloc(i);
            modepar(i).ind_fn = peakloc(i);
    end

   %plot the graph comparsion
   subplot(2,1,1), plot(fpoints, svalplot),
   xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'),xticks(fpoints(1):20:fpoints(end)) 
   ylabel('Magnitude (db)');
   subplot(2,1,2), plot(fpoints, svalplot(:,1),'-o','MarkerIndices',peakmarker,...
        'MarkerFaceColor','red'),
   xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'), xticks(fpoints(1):20:fpoints(end))
   ylabel('Magnitude (db)'); 
   pause;
   close all
else
    %set figure and plot the fdata
    fighandle = figure;
    plot(fpoints, mag2db(abs(fdata)));
    %plot(fpoints, abs(fdata));

    %set datacursormode
    dcm_obj = datacursormode(fighandle);
    set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on')

    disp('Select the peaks, and press enter if finished');
    pause

    %obtain the selected peak information
    peaks = getCursorInfo(dcm_obj);
    close(fighandle);

    for i=1:length(peaks)
        %save natural frequency
        modepar(i).fn = peaks(i).Position(1);

        %save peak values in db
        modepar(i).peakvaldb = peaks(i).Position(2);

        %obtain corresponding index of fn
        modepar(i).ind_fn = find(fpoints == modepar(i).fn);

    end
end


%save selected peaks into modepar struct
for i=1:length(modepar)
    %obtain index for modal coherence calculation
    indsvectors = [(modepar(i).ind_fn - nvalid/2 : modepar(i).ind_fn - 1) (modepar(i).ind_fn + 1 : modepar(i).ind_fn + nvalid/2)];
    
    if strcmp(modaltype,'ema')
        %save coh from auxar and modeshape from frf magnitude
        modepar(i).coh = auxvar(modepar(i).ind_fn);
        modepar(i).mshape = fdata(modepar(i).ind_fn,:)';
        svectors = fdata(indsvectors,:)';
    else
        %save modeshape from singular vectors
        modepar(i).mshape = auxvar(:,modepar(i).ind_fn,1);
        if ptype ~= 2
            svectors = auxvar(:,indsvectors,1);
        end
    end
    if ptype ~= 2
        modepar(i).modalcoh = modalcoherence(modepar(i).mshape, svectors);
        modepar(i).mac = mac_calc(modepar(i).mshape, svectors);
    end
end

%sort the structure
[~,isorted] = sort([modepar.fn]);
modepar = modepar(isorted);


%%%%%%%%%%% Helper Function %%%%%%%%%%%%%%
function modalcoh = modalcoherence(mshape, svectors)
% mshape and svector should be arranged as column vector

modalcoh = 0;
for i=1:size(svectors,2)
    modalcoh = modalcoh + abs(svectors(:,i)'*mshape);
end

modalcoh = modalcoh/size(svectors,2);


function macval=mac_calc(mshape,svectors)

macval = 0;
for i=1:size(svectors,2)
    tempval = (abs(svectors(:,i)'*mshape)).^2;
    sum1 = sum((svectors(:,i)'*svectors(:,i)),2);
    sum2 = sum((mshape'*mshape),2);
    macval = macval + tempval/sum1/sum2;
end
macval = macval/size(svectors,2);
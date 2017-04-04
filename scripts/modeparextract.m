function modepar = modeparextract(fdata, fpoints, modaltype, auxvar)
% function to plot frf/singular value and select peaks
%
% Parameter
% - fdata       : frf if ema, singular value if oma
% - fpoints     : frequency points fdata
% - modaltype   : type of modal analysis, 0 if EMA, 1 if OMA
% - auxvar      : auxillary variable. meancoherence if EMA, singular
%             vectors if OMA
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

%set figure and plot the fdata
fighandle = figure;
plot(fpoints, mag2db(abs(fdata)));

%set datacursormode
dcm_obj = datacursormode(fighandle);
set(dcm_obj,'DisplayStyle','datatip',...
'SnapToDataVertex','on','Enable','on')

disp('Select the peaks, and press enter if finished');
pause

%obtain the selected peak information
peaks = getCursorInfo(dcm_obj);
close(fighandle);

%create modepar struct to save data
modepar = struct([]);

%save selected peaks into modepar struct
for i=1:length(peaks)
    %save natural frequency
    modepar(i).fn = peaks(i).Position(1);

    %save peak values in db
    modepar(i).peakvaldb = peaks(i).Position(2);

    %obtain corresponding index of fn
    ind_fn = find(fpoints == modepar(i).fn);
    if strcmp(modaltype,'ema')
        %save coh from auxar and modeshape from frf magnitude
        modepar(i).coh = auxvar(ind_fn);
        modepar(i).mshape = fdata(ind_fn,:)';
    else
        %save modeshape from singular vectors
        modepar(i).mshape = auxvar(:,ind_fn,1);
    end
end

%sort the structure
[~,isorted] = sort([modepar.fn]);
modepar = modepar(isorted);

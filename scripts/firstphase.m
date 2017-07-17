function [npdata, modepar] = firstphase(data,nwindow,noverlap,fs)

%PARAMETER for peak area selection
peakband = 16; %in Hz
nwin = 4; %number of window used for auto psd
threshold = 0.3;

%obtain the fdd result
winsize = length(data.resvibdata)/nwindow;
fpoints = linspace(0,fs,winsize); %nfft is equal to winsize
fddres = fdd(data.resvibdata, hanning(winsize), 'hanning',winsize*noverlap, winsize, fs);

%obtain the peak area
parea = peakarea(data.resvibdata(1:winsize*nwin,:), nwin, noverlap*nwin, 500, peakband);
assignin('base', 'parea', parea)

%obtain the maximum peak value and noise floor for thresholding
nfloor = [];
peakdata = [];
for i=1:length(parea)
    sval1 = mag2db(abs(fddres.svalue(parea(i).start:parea(i).end,1)));
    sval5 = mag2db(abs(fddres.svalue(parea(i).start:parea(i).end,5)));

    nfloor = [nfloor; sval5];
    peakdata = [peakdata; sval1];
end
threshdata.nfloor = mean(nfloor);
threshdata.maxpeak = max(peakdata); %global maximum value in singular value
threshdata.value = threshdata.nfloor + threshold*(threshdata.maxpeak - threshdata.nfloor);


%apply modepar extraction for each peak area
modepar = [];
npdata = 0;;
for i=1:length(parea)
    %obtain data for each peak area
    sval = fddres.svalue(parea(i).start:parea(i).end,:);
    fpdata = fpoints(parea(i).start:parea(i).end);
    svec = fddres.svector(:,parea(i).start:parea(i).end,1);
    indexing = parea(i).start:parea(i).end;

    %count the number of data needed for all area
    npdata = npdata + parea(i).end - parea(i).start;
    
    %auto select the peaks
    modalresult =  automodal(sval, fpdata, svec, indexing, threshdata);

    %obtain the noise floor for thresholding
    if isempty(modalresult) == false
        modepar = [modepar, modalresult];
    end
end

%combine the peak information for plotting
k = 1;
for i=1:length(modepar)
    ploc(k) = modepar(i).ind_fn; 
    pmag(k) = modepar(i).peakvaldb;
    k = k+1;
end


%plot the range area
svalplot = mag2db(abs(fddres.svalue(:,1)));
plot(1:length(svalplot),svalplot,'linewidth',1);

%color the peak rangearea
for i=1:length(parea)
    hold on
    plot(parea(i).start:parea(i).end, ...
        svalplot(parea(i).start:parea(i).end), ...
        'Color',[0.9290    0.6940    0.1250], 'linewidth', 1);
end

%mark the selected peaks
plot(ploc,pmag,'*','MarkerEdgeColor',[0.8500    0.3250    0.0980], 'MarkerSize',10, 'linewidth', 2)
hold on

pause
close all



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------auto modal analysis function
function modepar = automodal(sval, fpoints, svector, indexing, threshdata)

%auto peak selection
svalplot = mag2db(abs(sval));
[smoothplot, peakloc, mag] = peakselect(svalplot(:,1),threshdata);

modepar = [];
for i=1:length(peakloc)
    %save natural frequency and mode shapes
    modepar(i).fn = fpoints(peakloc(i));
    modepar(i).mshape = svector(:,peakloc(i),1);

    %save peak values in db
    modepar(i).peakvaldb = mag(i);

    %obtain corresponding index of fn
    peakmarker(i) = peakloc(i);
    modepar(i).ind_fn = indexing(peakloc(i));
end

%plot the graph comparsion
if isempty(peakloc) == false
    subplot(2,1,1), plot(fpoints, svalplot),
    xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'),xticks(fpoints(1):20:fpoints(end)) 
    ylabel('Magnitude (db)');
    subplot(2,1,2), plot(fpoints, smoothplot,'-o','MarkerIndices',peakmarker,...
        'MarkerFaceColor','red'),
    xlim([fpoints(1) fpoints(end)]), xlabel('Frequency (Hz)'), xticks(fpoints(1):20:fpoints(end))
    ylabel('Magnitude (db)'); 
    pause;
    close all
else
    subplot(2,1,1)
    plot(fpoints, svalplot(:,1)),
    subplot(2,1,2)
    plot(smoothplot),
    pause;
    close all
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------modal peak selection function
function [smoothplot, peakloc, peakmag] = peakselect(data, threshdata)

%savitzky golay filter parameters;
lenorder = 3;
lenfilter = 13;

%length of data
datalen = length(data);

%threshold based on how dominant the true peak
pdom = (threshdata.maxpeak - threshdata.nfloor)/20;

%apply savitzky golay filtering
data = sgolayfilt(data, lenorder, lenfilter);

%finding the maxima and minima
j = 1;
pindex = [];
for i = 2:(datalen - 1)
    if (data(i) > data(i-1)) && (data(i) > data(i+1)) %maxima
        minmaxind(j) = i;
        minmaxmag(j) = data(i);
        j = j+1;
    elseif (data(i) < data(i-1)) && (data(i) < data(i+1)) %minima
        minmaxind(j) = i;
        minmaxmag(j) = data(i);
        j = j+1;
    end
end

minmaxind
minmaxmag

peakloc = [];
peakmag = [];

%start peak finding process
minmaxlen = length(minmaxind);
if minmaxlen == 1 
    disp('only 1 peak found');
    temploc = minmaxind;
    tempmag = minmaxmag;
elseif minmaxlen < 4
    [tempmag, loc] = max(minmaxmag);
    temploc = minmaxind(loc);    
else
    %the algorithm works by assuming the first data is maxima
    %check if the first index is maxima
    if minmaxmag(1) >= minmaxmag(2)
        i = 0
    else
        i = 1
    end

    %set initial values
    pind = 0;
    tempmaximag = min(minmaxmag);
    lvalley = min(minmaxmag);
    lvalleyloc = 1;
    foundpeak = false;
    temploc = [];
    tempmag = [];

    while i < minmaxlen
        i = i+1;

        %if peak obtained, reset the init values
        if foundpeak
            tempmaximag = min(minmaxmag);
            foundpeak = false;
        end

        %fprintf('current max %0.2f, new data %0.2f, last valley %0.2f\n',tempmaximag, minmaxmag(i),lvalley);
        %fprintf('pdom %0.2f\n',pdom);
        %found new maxima, check if larger than previous maxima
        %and dominant enough compared to left valley, based on threshold
        if (minmaxmag(i) > tempmaximag) && (minmaxmag(i) > lvalley + pdom)
            fprintf('new max found\n');
            tempmaximag = minmaxmag(i);
            tempmaxiloc = minmaxind(i);
        end

        if i == minmaxlen
            break; %avoid array out of index
        end

        %move to valley;
        i = i+1;

        %fprintf('current max %0.2f, new data %0.2f\n',tempmaximag, minmaxmag(i));
        if tempmaximag > minmaxmag(i) + pdom
            %peak obtained
            foundpeak = true;
            lvalley = minmaxmag(i);

            %save the peak
            pind = pind + 1;
            temploc(pind) = tempmaxiloc;
            tempmag(pind) = tempmaximag;
        elseif minmaxmag(i) < lvalley % New left valley
            lvalley = minmaxmag(i);
            lvalleyloc = minmaxind(i);
        end

    end
end

%apply threshold filtering
k = 1;
for i=1:length(temploc)
    if tempmag(i) > threshdata.value
        peakloc(k) = temploc(i);
        peakmag(k) = tempmag(i);
        k = k+1;
    end
end

%save the smoothed plot
smoothplot = data;





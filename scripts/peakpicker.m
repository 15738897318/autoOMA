function [peakloc, peakmag] = peakpicker(data,threshold, lenorder, lenfilter, plotgraph)
% function to find peaks automatically in a plot
%
% Parameter
% - data       : plot data
% - threshold  : how dominant the height of a data to be considered as a peak
%                from its surrounding valley
% - lenorder   : the order of savitzky golay filter used for smoothing (3 by default)
% - lenfilter  : the length savitzky golay filter used for smoothin (17 samples by default)
% - plotfilter : whether to show the plot and result or not (1 if plot, 0 otherwise)
%
% Output
% - peakloc     : peak locations
% - peakmag     : peak magnitudes
%
% The peak picking algorithm is based on peakfinder function by
% Nathanael C. Yoder 2015 (nyoder@gmail.com)
% https://nl.mathworks.com/matlabcentral/fileexchange/25500-peakfinder-x0--sel--thresh--extrema--includeendpoints--interpolate-?requestedDomain=www.mathworks.com

%savitzky golay filter parameters;
if nargin == 4
    plotgraph = 0;
elseif nargin == 2
    lenorder = 3;
    lenfilter = 17;
    plotgraph = 0;
end

data = data(1:end-1);

%threshold based on how dominant the true peak
pdom = (max(data)-min(data))/20;

%apply savitzky golay filtering
data = sgolayfilt(data, lenorder, lenfilter);

%the noise floor
nfloor = min(data);
datalen = length(data);

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

%start peak finding process
minmaxlen = length(minmaxind);
if minmaxlen < 3
    error('not sufficient peak candidate');
else
    %the algorithm works by assuming the first data is maxima
    %check if the first index is maxima
    if minmaxmag(1) >= minmaxmag(2)
        i = 0;
    else
        i = 1;
    end

    %set initial values
    pind = 0;
    tempmaximag = min(minmaxmag);
    lvalley = min(minmaxmag);
    lvalleyloc = 1;
    foundpeak = false;

    while i < minmaxlen
        i = i+1;

        %if peak obtained, reset the init values
        if foundpeak
            tempmaximag = min(minmaxmag);
            foundpeak = false;
        end

        %found new maxima, check if larger than previous maxima
        %and dominant enough compared to left valley, based on threshold
        if (minmaxmag(i) > tempmaximag) && (minmaxmag(i) > lvalley + pdom)
            tempmaximag = minmaxmag(i);
            tempmaxiloc = minmaxind(i);
        end

        %move to valley;
        i = i+1;
        if i == minmaxlen-1
            break; %avoid array out of index
        end

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

%apply the thresholding value
pthreshold = nfloor + threshold * (max(tempmag) - nfloor);
k = 1;
for i=1:length(temploc)
    if tempmag(i) > pthreshold
        peakloc(k) = temploc(i);
        peakmag(k) = tempmag(i);
        k = k+1;
    end
end

%plot if option selected and no output desired
if nargout == 0 || plotgraph == 1
    if isempty(peakloc)
        disp('No significant peaks found')
    else
        figure;
        plot(1:datalen,data,'.-',peakloc,peakmag,'ro','linewidth',2);
    end
end
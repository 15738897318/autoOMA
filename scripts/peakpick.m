function [fpoints,raw,smth] = peakpick(input, window, overlap, nfft, fs, frange)
%
% result is 2d array of structs, column represents sensor channel
% row represents number of window (data is sliced into several
% overlapping windows for PSD calculation). The structure consists of:
% - pfreq     : frequency of selected peak 
% - pareafreq : frequency of selected peak and neigjboring points (peak index
%               is always located in the center of this data)
% - pval      : value of the selected peak 
% - pareaval  : values of selected peak and neighboring points (peak is located
%               as same as nfreq)

% calculate the frequency resolution range
fpoints = linspace(0,fs,nfft);
fpoints = fpoints(1:(nfft/2+1));

%if user specify frequency range, determine closest frequency available
if nargin == 6
  [val i_fmin] = min(abs(fpoints - frange(1)));
  [val i_fmax] = min(abs(fpoints - frange(2)));
else
  i_fmin = 1;
  i_fmax = length(fpoints);
end
fmin = fpoints(i_fmin);
fmax = fpoints(i_fmax);

% calculate the sizes
datalen = size(input,1);
nchannel = size(input,2);
wsize = length(window);

%check if window and overlap fit to input length
inputrem = mod(datalen - wsize, wsize - overlap);
if inputrem ~= 0
    fprintf('WARNING : window & overlap size does NOT fit to input length, ');
    fprintf('trimming input by %d\n',inputrem);
    input = input(1:end-inputrem,:);
end

%clear the mean
for ichannel = 1:nchannel
    input(:,ichannel) = input(:,ichannel) - mean(input(:,ichannel));
end

% calculate fft for eeach window
for ichannel = 1:nchannel
    istart = 1;
    iend = wsize;
    iwindow = 1;

    %fft result is stored in 3d array, row is fft result, depth is number of window
    while iend <= datalen
        tempfft = fft(input(istart:iend,ichannel), nfft);
        tempfft = tempfft(1 : end/2+1);
        fftres(:,ichannel,iwindow) = tempfft;

        iwindow = iwindow + 1;
        istart = istart + (wsize - overlap);
        iend = iend + (wsize - overlap);
    end
end


% calculate psd
for ichannel=1:nchannel
    psdres(:,ichannel) = pwelch(input(:,ichannel),window,overlap,nfft,fs);
    psdfiltered(:,ichannel) = sgolayfilt(psdres(:,ichannel),4,2.*round(length(psdres(:,ichannel))/1000)+1);
end

raw = psdres;
smth = psdfiltered;
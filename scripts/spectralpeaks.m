function sensor = spectralpeaks(data, winsplit, overlap, fs, nodeid)

if nargin == 4
    nodeid = [94,95,96,97,98,99];
end

%iterate through sensor channel
for i=1:size(data,2)
    %calculate the power spectral density
    len = length(data(:,i));
    winsize = len/winsplit;
    overlap = overlap*winsize;
    
    %obtain the psd
    [spectra, f] = pwelch(data(:,i) - mean(data(:,i)), hanning(winsize),overlap, winsize, fs);
    
    %convert to db magnitude
    spectra = mag2db(abs(spectra));
    
    %find the peaks
    [loc,mag] = peakpicker(spectra,0.4,3,33,1);

    %save the result in structure
    sensor(i).nodeid = nodeid(i);
    sensor(i).ploc = loc;
    sensor(i).pfloc = f(sensor(i).ploc); %peak location in frequency
    sensor(i).pmag = mag; 
    
    pause
    close all
end



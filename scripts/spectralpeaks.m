function specpeaks = spectralpeaks(data, winsplit, overlap, fs, nodeid)

for i=1:size(data,2)
    %calculate the power spectral density
    len = length(data(:,i));
    winsize = len/winsplit;
    overlap = overlap*winsize;
    
    %obtain the psd
    [spectra, f] = pwelch(data(:,i) - mean(data(:,i)), hanning(winsize),overlap, winsize, fs);
    
    %convert to db magnitude
    spectra = mag2db(abs(spectra(:,1)));
    
    %find the peaks
    [loc,mag] = peakpicker(spectra,0.4,3,17,1);

    %save the result in structure
    specpeaks(i).nodeid = nodeid(i);
    specpeaks(i).loc = loc;
    specpeaks(i).floc = f(specpeaks(i).loc); %peak location in frequency
    specpeaks(i).mag = mag; 
    
    pause
    close all
end



function specpeaks = spectralpeaks(data, minheight, winsplit, fs, nodeid)

for i=1:size(data,2)
    %calculate the power spectral density
    overlap = winsplit*2;
    len = length(data(:,i));
    [spectra, f] = pwelch(data(:,i) - mean(data(:,i)), hanning(len/winsplit),len/overlap, len/winsplit, fs);

    %conver to db magnitude
    spectra = mag2db(abs(spectra));

    %apply savitzky golay smoothing
    spectra = sgolayfilt(spectra,4,257);

    %find the peaks
    [loc,mag] = peakfinder(spectra,minheight,[],[],0,0);

    %save the result in structure
    specpeaks(i).nodeid = nodeid(i);
    specpeaks(i).loc = loc;
    specpeaks(i).floc = f(specpeaks(i).loc); %peak location in frequency
    specpeaks(i).mag = mag; 

    pause
    close all
end



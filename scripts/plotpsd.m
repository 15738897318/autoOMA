function result = plotpsd(data,winsplit,fs)
len = length(data)
overlap = 0.5*len/winsplit

[spectra, f] = pwelch(data - mean(data), hanning(len/winsplit), overlap, len/winsplit, fs);
plot(f,mag2db(abs(spectra)));
xlim([f(1) f(end)]);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
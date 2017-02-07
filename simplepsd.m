function psd = simplepsd(signal1,signal2,window,nfft,fs)

%remove the dc component
signal1 = signal1 - mean(signal1);
signal2 = signal2 - mean(signal2);

%apply window
signal1 = signal1.*window;
signal2 = signal2.*window;

%calculate fft
fdata1 = fft(signal1, nfft);
fdata2 = fft(signal2, nfft);

%delete the last half of frequency fdata1
fdata1 = fdata1(1:(nfft/2+1);
fdata2 = fdata2(1:(nfft/2+1);

%calculate the psd
psd = fdata1.*conj(fdata2);
psd = psd./fs;
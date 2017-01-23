function [mfreq,mshape] = pickpeaking(input,window,overlap,nfft,fs)

%calculate the frequency resolution range
fres = linspace(0,fs,nfft);
fres = fres(1:(nfft/2+1));

%obtain the number of sensors/channel
nchannel = size(input,2);

%obtain the average psd
autopsd = zeros((nfft/2+1),1);
for i=1:nchannel
	input(:,i) = input(:,i) - mean(input(:,i));
  autopsd = autopsd + cpsd(input(:,i),input(:,i),window,overlap,nfft,fs);
end
autopsd = autopsd/nchannel;

figure,
plot(fres,autopsd);
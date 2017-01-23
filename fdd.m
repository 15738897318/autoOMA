function [mfreq,mshape] = fdd(input,window,overlap,nfft,fs)

% Freqyency Domain Decomposition (FDD) algorithm
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 23/01/2017
% 
% Function Parameters
% input   : input time domain data (matlab format), row as time series, column as data channel
% window  : window (as vector) for welch psd estimation. Example : hanning(128)
% overlap : overlap between window segments for welch psd estimation
% nfft    : number of fft point to be used
% fs      : sampling rate of data
%
% Example:
% 128 sampling rate, 1024 point fft, with hannning window of 128 samples and overlap of 64 samples
% [freq,mshape] = FDD(data, hanning(128), 64, 1024, 128);


% calculate the frequency resolution range
fres = linspace(0,fs,nfft);
fres = fres(1:(nfft/2+1));

%remove the dc component
for i=1:size(input,2)
   input(:,i) = input(:,i) - mean(input(:,i)); 
end

% Obtain the cpsd matrix
for i=1:size(input,2)
  for j=1:size(input,2)
    psd(i,j,:) = cpsd(input(:,i),input(:,j),window,overlap,nfft,fs);
  end
end

% Calculate the SVD of cpsd matrix for each frequency
nsingular = 3; %number of singular values to be saved
for i=1:size(psd,3)
  [u,s,~] = svd(psd(:,:,i));
  for j=1:nsingular
    svalue(i,j) = s(j,j);
    svector(:,i,j) = u(:,j);
  end
end

% Plot the singular values of psd matrix
figure
plot(fres, mag2db(svalue(:,1)));
hold on
plot(fres, mag2db(svalue(:,2)));
plot(fres, mag2db(svalue(:,3)));

mfreq = svalue;
mshape = svector;
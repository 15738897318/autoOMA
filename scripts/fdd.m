function [fpoints, svalue, svector] = fdd(input,window,overlap,nfft,fs)

% Frequency Domain Decomposition (FDD) algorithm
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
fpoints = linspace(0,fs,nfft);
fpoints = fpoints(1:(nfft/2+1));

%obtain the cross-psd matrix
disp('Calculating cross-psd matrix -----');
tic
psd = cpsdm(input,window,overlap,nfft,fs);
toc
% Calculate the SVD of cpsd matrix for each frequency
nsingular = 6; %number of singular values to be saved
disp('Calculating SVD -----');
tic
for i=1:size(psd,3)
  [u,s,~] = svd(psd(:,:,i));
  for j=1:nsingular
    svalue(i,j) = s(j,j);
    svector(:,i,j) = u(:,j);
  end
end
toc

% Plot the singular values of psd matrix
disp('Plotting SVD -----');
tic
figure
plot(fpoints, mag2db(abs(svalue(:,1))));
hold on
plot(fpoints, mag2db(abs(svalue(:,2))));
plot(fpoints, mag2db(abs(svalue(:,3))));
toc
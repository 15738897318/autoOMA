function [fpoints psd] = batchpsd(input1, input2, window, overlap, nfft, fs)
% Calculate psd matrix of batch of time domain data
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 21/02/2017
% 
% Function outputs:
% fpoints : frequency points of the psd
% psd     : resulted psd matrix
%
% Function Parameters
% input1  : first input time domain data (matlab format), row as time series, column as data channel
% input2  : second input time domain data (matlab format), row as time series, column as data channel
% window  : window (as vector) for welch psd estimation. Example : hanning(128)
% overlap : overlap between window segments for welch psd estimation
% nfft    : number of fft point to be used
% fs      : sampling rate of data
%
% Example:
% crosspsd of a and b, 128 sampling rate, 1024 point fft, with hannning window of 128 samples and overlap of 64 samples
% psd = batchpsd(a, b, hanning(128), 64, 1024, 128);
%
% autopsd of a, 128 sampling rate, 1024 point fft, with hannning window of 128 samples and overlap of 64 samples
% psd = batchpsd(a, a, hanning(128), 64, 1024, 128);

%check if input2 and input2 has same size and dimension
if ~isequal(size(input1),size(input2))
  error('Input 1 and input 2 doesn NOT have same matrix size')
end

%calculate the frequency points
fpoints = linspace(0,fs,nfft);
fpoints = fpoints(1:(nfft/2+1));

for i=1:size(input1,2)
  %remove the dc component
  input1(:,i) = input1(:,i) - mean(input1(:,i));
  input2(:,i) = input2(:,i) - mean(input2(:,i));

  %calculate the psd
  psd(:,i) = cpsd(input1(:,i),input2(:,i),window,overlap,nfft,fs);
end
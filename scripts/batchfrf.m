function [fpoints, frf, coh] = batchfrf(input, output, window, overlap, nfft, fs)
% Calculate FRF matrix of batch of output and input time domain data
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 21/02/2017
% 
% Function outputs:
% fpoints : frequency points of the frf
% frf     : resulted frf matrix
% coh     : coherence between input and ouptut
%
% Function Parameters
% input   : input data, row as time series, column as data channel
% output  : ouput data, row as time series, column as data channel
% window  : window (as vector) for welch psd estimation. Example : hanning(128)
% overlap : overlap between window segments for welch psd estimation
% nfft    : number of fft point to be used
% fs      : sampling rate of data
%
% Example:
% frf of input A and output B, 128 sampling rate, 1024 point fft, with hannning window of 128 samples and overlap of 64 samples
% frf = batchfrf(A, B, hanning(128), 64, 1024, 128);

%check if input and output has same size and dimension
if ~isequal(size(input),size(output))
  error('Input and output does NOT have same size')
end

%calculate input-output crosspd and input autopsd
[fpoints, inpsd] = batchpsd(input,input, window, overlap, nfft, fs);
[fpoints, crosspsd] = batchpsd(input, output, window, overlap, nfft, fs);
% [fpoints, outpsd] = batchpsd(output,output, window, overlap, nfft, fs);

%calculate the frf
frf = crosspsd./inpsd;
% frf = outpsd./crosspsd;

%calculate the coherence
coh = mscohere(output,input, window, overlap, nfft, fs);
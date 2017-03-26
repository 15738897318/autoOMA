function result = batchfrf(input, output, window, wintype, overlap, nfft, fs)
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
% wintype : window type being used, as string. Example : 'hanning', 'hamming'
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

%create structure to save all of the results
result = struct('fpoints', fpoints);
result.frf = frf;
result.meanfrf = mean(frf,2);
result.coh = coh;
result.meancoh = mean(coh,2);
result.type = 'ema';

%save the psdsetting as well
result.psdsetting = struct('fsampling', fs, 'window',window, ...
                    'wintype', wintype, 'overlap', overlap, 'nfft', nfft);



%----------------  Helper Functions -------------------

function [fpoints psd] = batchpsd(input1, input2, window, overlap, nfft, fs)
% Calculate psd matrix of batch of time domain data
% 
% Function outputs:
% fpoints : frequency points of the psd
% psd     : resulted psd matrix
%
% Function Parameters
% input1  : first input time domain data (matlab format), row as time series, column as data channel
% input2  : second input time domain data (matlab format), row as time series, column as data channel
% everything else is as explained in main functions

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
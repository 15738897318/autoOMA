function result = fdd(input,window, wintype, overlap,nfft, fs, frange)

% Frequency Domain Decomposition (FDD) algorithm
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 23/01/2017
% 
% Function Parameters
% input   : input time domain data (matlab format), row as time series, column as data channel
% window  : window (as vector) for welch psd estimation. Example : hanning(128)
% wintype : window type being used, as string. Example : 'hanning', 'hamming'
% overlap : overlap between window segments for welch psd estimation
% nfft    : number of fft point to be used
% fs      : sampling rate of data
% frange  : optional two member array [fmin fmax] to determine the frequency range fdd will be
%           applied on. Example [0 3000], will apply fdd from 0 Hz to 3000 Hz only
%
% Output
% fpoints : frequency points of singular value and psd matrix
% svalue  : singular value, only from 1st to 6th 
% svector : corresponding singular vector for each singular value
% psd     : psd matrix of time series data
%
% Example:
% 128 sampling rate, 1024 point fft, with hannning window of 128 samples and overlap of 64 samples
% FDD(data, hanning(128), 64, 1024, 128);

% calculate the frequency resolution range
fpoints = linspace(0,fs,nfft);
fpoints = fpoints(1:(nfft/2+1));

%if user specify frequency range, determine closest frequency available
if nargin == 7
  [val i_fmin] = min(abs(fpoints - frange(1)));
  [val i_fmax] = min(abs(fpoints - frange(2)));
else
  i_fmin = 1;
  i_fmax = length(fpoints);
end
fmin = fpoints(i_fmin);
fmax = fpoints(i_fmax);
fpoints = fpoints(i_fmin : i_fmax);

%obtain the cross-psd matrix
disp('Calculating cross-psd matrix -----');
tic
psd = cpsdm(input,window,overlap,nfft,fs);
toc

%throw away unnecessary points
psd = psd(:,:,i_fmin:i_fmax);

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

%crete structure to save all of the results
result = struct('fpoints', fpoints);
result.svalue = svalue;
result.svector = svector;
result.psdm = psd;
result.type = 'oma';

%save the psdsetting as well
result.psdsetting = struct('fsampling', fs, 'window',window, ...
                    'wintype', wintype, 'overlap', overlap, ...
                    'nfft', nfft, 'fmin', fmin, 'fmax', fmax);


% -------------------- Helper Functions ------------------- %

function psd = cpsdm(input,window,overlap,nfft,fs)
%calculate psd matrix

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
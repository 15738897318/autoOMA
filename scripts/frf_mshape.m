function modepar = frf_mshape(fn, fpoints, frf, findreal);
% extract mode shape from batch of frf by specifing the natural frequency
% based on simple peak picking method on experimental modal analysis
%
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 21/02/2017
%
% Function parameters:
% fn      : chosen natural frequencies for modeshape extract
% fpoints : frequency points of each frf data (e.g. [0Hz 0.5Hz 1Hz 1.5Hz])
% frf     : frequency response function. row as frequency data, column as sensing channel
% findreal: logic 1 or 0. insert 1 if mode shape to be extracted from real part of frf, 0 otherwise
%
% Function outputs:
% modepar : struct(s) that contain 3 fields. 
%           - fn    : natural frequency
%           - index : array index of corresponding natural frequency in frf
%           - mshape: mode shape data of corresponding natural frequency

%find the frequency location
for i=1:length(fn)
  [c index] = min(abs(fpoints-fn(i)));
  modepar(i) = struct('fn',fn(i),'index',index,'mshape',[]);
end

if findreal
  for i=1:length(modepar)
    modepar(i).mshape = real(frf(modepar(i).index,:));
  end
else
  for i=1:length(modepar)
    modepar(i).mshape = imag(frf(modepar(i).index,:));
  end
end
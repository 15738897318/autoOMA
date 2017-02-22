function modepar = frf_mshape(fn, fpoints, frf);
% extract mode shape from batch of frf by specifing the natural frequency
% based on simple peak picking method on experimental modal analysis
%
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 22/02/2017
%
% Function parameters:
% fn      : chosen natural frequencies for modeshape extract
% fpoints : frequency points of each frf data (e.g. [0Hz 0.5Hz 1Hz 1.5Hz])
% frf     : frequency response function. row as frequency data, column as sensing channel
%
% Function outputs:
% modepar : struct(s) that contain 3 fields. 
%           - fn    : natural frequency
%           - index : array index of corresponding natural frequency in frf
%           - mshape: complex (full) mode shape data of corresponding natural frequency
%           - realmshape: real part of mode shape data of corresponding natural frequency
%           - imagmshape: imaginary part of mode shape data of corresponding natural frequency

%find the frequency location
for i=1:length(fn)
  [c index] = min(abs(fpoints-fn(i)));
  modepar(i) = struct('fn',fn(i),'index',index,'mshape',[]);
end

%extract the modeshape
for i=1:length(modepar)
  modepar(i).mshape = frf(modepar(i).index,:);
  modepar(i).realmshape = real(modepar(i).mshape);
  modepar(i).imagmshape = imag(modepar(i).mshape);
end

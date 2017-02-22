function modepar = fdd_mshape(fn, fpoints, svalue, svector);
% extract mode shape from fdd result by specifing the natural frequency
% based on simple peak picking method on experimental modal analysis
%
% Author: Alkindi R. Dzulqarnain, Master Student at UTwente
% Last update: 22/02/2017

%find the frequency location
for i=1:length(fn)
  [c index] = min(abs(fpoints-fn(i)));
  modepar(i) = struct('fn',fn(i),'index',index,'mshape',[]);
end

%select corresponding singular vector
%extract the modeshape
for i=1:length(modepar)
  modepar(i).mshape = svector(:,modepar(i).index);
  modepar(i).realmshape = real(modepar(i).mshape);
  modepar(i).imagmshape = imag(modepar(i).mshape);
end
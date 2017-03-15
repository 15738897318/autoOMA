function plot_modeshape(modepar)

ssize = get(0,'ScreenSize');
ssize = ssize + [50 50 -150 -150];
figh = figure('position',ssize);

index = 1;
while index <= length(modepar)
  figure(figh), subplot(2,2,1), surf(modepar(index).regrid);
  title(sprintf('fn = %0.2f Hz',modepar(index).fn));

  figure(figh), subplot(2,2,2), surf(modepar(index+1).regrid);
  title(sprintf('fn = %0.2f Hz',modepar(index+1).fn));

  figure(figh), subplot(2,2,3), surf(modepar(index+2).regrid);
  title(sprintf('fn = %0.2f Hz',modepar(index+2).fn));

  figure(figh), subplot(2,2,4), surf(modepar(index+3).regrid);
  title(sprintf('fn = %0.2f Hz',modepar(index+3).fn));
  
  index = index + 4;
  pause
end
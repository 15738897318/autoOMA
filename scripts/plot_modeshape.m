function plot_modeshape(ema_modepar, oma_modepar)
% Plot modeshape result in geometry plot
if length(ema_modepar) ~= length(oma_modepar)
  error('OMA struct size is different than EMA');
end

j=1;
for i=1:length(ema_modepar)
  subplot(2,2,j), surf(ema_modepar(i).regrid);
  subplot(2,2,j+1), surf(oma_modepar(i).regrid);
  j = j + 2;

  if j >= 4;
    j = 1;
    pause
  end
end




newtstamp = bridgedata(1).tstamp - min(bridgedata(1).tstamp);
plotdata = (bridgedata(1).resvibdata(:,1) - mean(bridgedata(1).resvibdata(:,1)))*9.80665;
plot(newtstamp,plotdata,'Color',[0    0.4470    0.7410]);
xlim([newtstamp(1) newtstamp(end)]);
xlabel('Time (s)');
ylabel('Acceleration (m/s^{2})');

pause;

for i=1:2
    fdata = disresult.sdata(i).svalue(:,1);
    filorder = 2;
    fillength = 2*floor(length(fdata)/3/2)+1;
    svalplot = mag2db(abs(fdata));
    svalsmooth = sgolayfilt(svalplot,filorder,fillength);
    plot(disresult.sdata(i).fpoints,svalsmooth,'Color',[0    0.4470    0.7410]);
    xlim([disresult.sdata(i).fpoints(1) disresult.sdata(i).fpoints(end)]);
    xlabel('Frequency (Hz)');
    ylabel('First Singular Value Magnitude (dB)');
    
    hold on
    floc = disresult.sdata(i).fpoints(disresult.modepar(i).ind_fn);
    mag = disresult.modepar(i).peakvaldb;
    plot(floc,mag,'*','MarkerEdgeColor','black', 'MarkerSize',4, 'linewidth', 2)
    txt = strcat('\leftarrow ',num2str(disresult.modepar(i).fn,'%0.3f Hz'));
    text(floc,mag,txt)
    
    pause;
end
close all;

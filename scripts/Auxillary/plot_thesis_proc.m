specpeaks = spectralpeaks(bridgedata(1).resvibdata(1:2048*4,:), 4, 0, 500, bridgedata(1).nodeid);
fpoints = linspace(0,500,2048);
fres = 500/2048;
pband = 2*floor(16/fres/2);

for i=2:2:4
    splot = sgolayfilt(specpeaks(i).spectra(1:1024), 3, 33);
    plot(fpoints(1:1024), splot);
    xlim([fpoints(1) fpoints(1024)])
    xlabel('Frequency (Hz)');
    ylabel('PSD Magnitude (dB)');
    hold on
    
    plot(specpeaks(i).pfloc,specpeaks(i).pmag,'*','MarkerEdgeColor','black', 'MarkerSize',4, 'linewidth', 2)
    
    %plot parea
    for j=1:length(specpeaks(i).ploc)
        hold on
        pstart = specpeaks(i).ploc(j) - pband/2;
        pend = specpeaks(i).ploc(j) + pband/2;
        plot(fpoints(pstart:pend), ...
            splot(pstart:pend), ...
            'Color',[0.8500    0.3250    0.0980], 'linewidth', 1);
        
        %plot text
        txt = strcat(num2str(fpoints(pstart),'%0.3f Hz'),'\rightarrow ');
        h = text(fpoints(pstart),splot(pstart),txt,'HorizontalAlignment','right','Color',[0.8500    0.3250    0.0980],'VerticalAlignment','middle');
        set(h, 'rotation', -80);
        
        txt = strcat('\leftarrow ',num2str(fpoints(pend),'%0.3f Hz'));
        h = text(fpoints(pend),splot(pend),txt,'Color',[0.8500    0.3250    0.0980],'VerticalAlignment','middle');
        set(h, 'rotation', -80);
        
        txt = strcat('-------',num2str(specpeaks(i).pfloc,'%0.3f Hz'));
        h = text(specpeaks(i).pfloc,specpeaks(i).pmag,txt);
        set(h, 'rotation', -90);
    end
    
    legend('Unused Frequencies','Peak Location','Peak Area')
    pause
    close all
    
    i = 5;
    splot = sgolayfilt(mag2db(abs(resultauto(1).svalue(parea(i).start:parea(i).end,1))), 3, 13);
    plot(resultauto(1).fpoints(parea(i).start:parea(i).end), ...
        splot, ...
        'Color',[0.9290    0.6940    0.1250], 'linewidth', 1);
    hold on
    plot(resultauto(1).modepar(4).fn,resultauto(1).modepar(4).peakvaldb,'*','MarkerEdgeColor','black', 'MarkerSize',4, 'linewidth', 2)
    xlabel('Frequency (Hz)');
    ylabel('First Singular Value Magnitude (dB)');
    
    txt = strcat('\leftarrow ',num2str(resultauto(1).modepar(4).fn,'%0.3f Hz'));
    h = text(resultauto(1).modepar(4).fn,resultauto(1).modepar(4).peakvaldb,txt,'VerticalAlignment','middle');
    pause
    close all
end
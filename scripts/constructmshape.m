function modepar = constructmshape(modepar, gridres, type)

ax = 210
az = 55

if type==1 %pit bridge
    for j=1:length(modepar) 
        modepar(j).paddedmshape = [0; modepar(j).mshape(3); modepar(j).mshape(6); 0; ...
                                   0; modepar(j).mshape(2); modepar(j).mshape(5); 0; ...
                                   0; modepar(j).mshape(1); modepar(j).mshape(4); 0];
    end


    len = 4;
    bridgeid = 'pitbridge';
elseif type==2 %steel bridge
    for j=1:length(modepar)
        modepar(j).paddedmshape = [0; modepar(j).mshape(1:3); 0; ...
                                   0; modepar(j).mshape(4:6); 0];
    end

    len = 5;
    bridgeid = 'steelbridge';
else %wood bridge
    for j=1:length(modepar)
        modepar(j).paddedmshape = [0; modepar(j).mshape(1:3); 0; ...
                                   0; modepar(j).mshape(4:6); 0];
    end

    len = 5;
    bridgeid ='woodbridge';
    ax = 240
    az = 45
end

modepar= mshape_grid(modepar, len, gridres)

figure,
for i=1:length(modepar)
    %plot the modeshape
    surf(modepar(i).imgrid)
    set(gca, 'visible', 'off') ;
    view(ax,az)

    %save the plot as files
    plotname = strcat(bridgeid,'_mshape_', num2str(i),'.jpg');
    saveas(gcf,plotname);
    pause
end

close all

for i=1:6
    len = length(procdata(i).resvibdata)
    result(i) = fdd(procdata(i).resvibdata, hanning(len/8), 'hanning',len/16, len/8, 1000)
end

for i=1:6
    result(i).modepar = modeparextract(result(i).svalue, result(i).fpoints, 'oma', result(i).svector)
end

for i=1:5
    macval12(i) = MAC(result(1).modepar(i).mshape, result(2).modepar(i).mshape);
    macval13(i) = MAC(result(1).modepar(i).mshape, result(3).modepar(i).mshape);
    macval23(i) = MAC(result(2).modepar(i).mshape, result(3).modepar(i).mshape);
end

macval12 = macval12'
macval13 = macval13'
macval23 = macval23'

for i=1:length(testvib)
    for j=1:length(testvib(i).oma.modepar)
        testvib(i).oma.modepar(j).mshape = [0;testvib(i).oma.modepar(j).mshape(1:3); 0;0; testvib(i).oma.modepar(j).mshape(4:6);0];
    end
    testvib(i).oma.modepar = mshape_grid(testvib(i).oma.modepar, 5, 0.25);
end


---------------------------------------------------------------
script for new steel bridge measurement

%for splitting data into 4
nsplit = 3
len = length(steelbridge.resvibdata)./nsplit
len = len - mod(len,16);
sindex = 1
eindex = len
for i=1:nsplit
    sbridge(i).vibdata =  steelbridge.vibdata(sindex:eindex,:);
    sbridge(i).resvibdata =  steelbridge.resvibdata(sindex:eindex,:);
    sbridge(i).tstamp =  steelbridge.tstamp(sindex:eindex,:);
    sbridge(i).tsample =  steelbridge.tsample/nsplit;
    sindex = sindex + len;
    eindex = eindex + len;
end

%ontain modal parameter
for i=1:length(sbridge)
    len = length(sbridge(i).resvibdata);
    result(i) = fdd(sbridge(i).resvibdata, hanning(len/8), 'hanning',len/16, len/8, 500)
end

%for curved steel bridge
for i=1:length(sbridge)
    result(i).modepar = modeparextract(result(i).svalue, result(i).fpoints, 'oma', result(i).svector)

    for j=1:length(result(i).modepar)
        result(i).modepar(j).mshape = [0;result(i).modepar(j).mshape(1:3); 0;0; result(i).modepar(j).mshape(4:6);0];
    end

    result(i).modepar = mshape_grid(result(i).modepar, 5, 0.25);
end


%special for pit bridge
for i=1:length(sbridge)
    result(i).modepar = modeparextract(result(i).svalue, result(i).fpoints, 'oma', result(i).svector)

    for j=1:length(result(i).modepar)
        result(i).modepar(j).mshape = [0;result(i).modepar(j).mshape(3); result(i).modepar(j).mshape(6); 0; 0; result(i).modepar(j).mshape(2); result(i).modepar(j).mshape(5); 0; 0; result(i).modepar(j).mshape(1); result(i).modepar(j).mshape(4);0];
    end

    result(i).modepar = mshape_grid(result(i).modepar, 4, 0.25);
end
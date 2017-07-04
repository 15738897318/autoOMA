function result = distributedfdd(data,modepar,fband, nwindow,noverlap,fs)
%modepar contain the info for previous selected peaks

for i=1:length(modepar)
    %obtain the start and end frequency around peaks
    sfreq = modepar(i).fn - fband/2;
    efreq = modepar(i).fn + fband/2;

    %obtain the fdd result for each peaks
    len = length(data.resvibdata)/nwindow;
    sdata(i) = fdd(data.resvibdata, hanning(len), 'hanning',len*noverlap, len, fs, [sfreq efreq]);
    length(sdata(i).svalue)
    % plot(result(i).fpoints,mag2db(abs(result(i).svalue)));
    % pause
end

%Auto select the singular values
for i=1:length(sdata)
    newmodepar(i) = modeparextract(sdata(i).svalue, sdata(i).fpoints, 'oma', sdata(i).svector, 2) 
end

for i=1:length(newmodepar)
    newmodepar(i).comparemac = MAC(modepar(i).mshape, newmodepar(i).mshape)
end

%combine the data
result.sdata = sdata;
result.modepar = newmodepar;
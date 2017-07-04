function result = autofdd(data,nwindow,noverlap,fs,auto,limit)

%obtain th fdd results
for i=1:length(data)
    len = length(data(i).resvibdata)/nwindow;
    result(i) = fdd(data(i).resvibdata, hanning(len), 'hanning',len*noverlap, len, fs)
    %plot(mag2db(abs(result(i).svalue)));
    %pause
end

%Auto select the singular values
for i=1:length(result)
    result(i).modepar = modeparextract(result(i).svalue, result(i).fpoints, 'oma', result(i).svector, auto)
end


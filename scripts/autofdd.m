function result = autofdd(data,nwindow,noverlap,fs,auto)
% Automatically or manually batch process set of vibration signals into 
% modal parameters (natural frequencies & mode shape) using FDD algorithm
%
% Parameter
% - data     : vibration signal data
% - nwindow  : number of windows for PSD estimation
% - noverlap : number of samples overlap between window for PSD estimation
% - fs       : sampling rate used in signal
% - auto     : pick the peaks in singular value plot manually (0) or automatically (1)
% 
% Output
% - result : structure contains the process result (singular value, vectors, and modal parameters)

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


function modepar = mpeakselect(fdata, fpoints, meancoh)
% function to plot frf/singular value and select peaks
%
% Parameter
% - fdata   : frf if ema, singular value if oma
% - fpoints : frequency points fdata
% - meancoh : mean coherence value of frfs, only for ema
%
% Output
% - modepar : structure that contains selected frequency, peak values, and
%             coherence in ema.

% check if oma or ema, oma shouldn't have coherence data
if nargin == 2
    oma = 1;
elseif nargin == 3
    oma = 0;
end

%set figure and plot the fdata
fighandle = figure;
plot(fpoints, mag2db(abs(fdata)));

%set datacursormode
dcm_obj = datacursormode(fighandle);
set(dcm_obj,'DisplayStyle','datatip',...
'SnapToDataVertex','on','Enable','on')

disp('Select the peaks, and press enter if finished');
pause

%obtain the selected peak information
peaks = getCursorInfo(dcm_obj);
close(fighandle);

%create modepar struct to save data
modepar = struct([]);

%save selected peaks into modepar struct
for i=1:length(peaks)
    modepar(i).fn = peaks(i).Position(1);
    modepar(i).peakvaldb = peaks(i).Position(2);

    %save coherence value, only for ema
    if oma == 0
        modepar(i).coh = meancoh(find(fpoints == modepar(i).fn));
    end
end

%sort the structure
[~,isorted] = sort([modepar.fn]);
modepar = modepar(isorted);
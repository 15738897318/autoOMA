function parea = peakarea(data, winsplit, overlap, fs, pband)

if nargin == 4
    pband = 10; %default set to 10Hz
end

%parmeter values
datalen = length(data);
nfft = datalen/winsplit;
fres = fs/nfft;
pband = 2*floor(pband/fres/2); %change into index width
fpoints = linspace(0,fs,nfft);

%find the peaks
sensor = spectralpeaks(data, winsplit, overlap, fs);

%reate a sets of peak area intervals
kk = 1;
for i = 1 : length(sensor)
    for jj = 1 : length(sensor(i).ploc)
        pinterval(kk).start = sensor(i).ploc(jj) - pband/2;
        pinterval(kk).end = sensor(i).ploc(jj) + pband/2;

        if(pinterval(kk).start < 1)
            pinterval(kk).start = 1;
        end

        if(pinterval(kk).end > datalen)
            pinterval(kk).end = datelen;
        end

        kk = kk + 1;
    end
end

assignin('base', 'pinterval', pinterval)

%merge the intervals
i = 1;
while isempty(pinterval) == false
    %reset the candidate agains
    candidate = pinterval(1);
    areacount = 1;

    for kk = i : length(pinterval);
        if pinterval(kk).start < candidate.start
            if pinterval(kk).end < candidate.start
                fprintf('new area before,nstart %d, nend %d, oldstart %d, oldend %d \n',pinterval(kk).start, pinterval(kk).end, candidate.start, candidate.end);
                %new area found
                newarea(areacount).start = pinterval(kk).start;
                newarea(areacount).end = pinterval(kk).end;
                areacount = areacount + 1;
            elseif pinterval(kk).end < candidate.end;
                %intersect with current area
                candidate.start = pinterval(kk).start;
            else
                %supercede the current area
                candidate.start = pinterval(kk).start;
                candidate.end = pinterval(kk).end;
            end
        elseif pinterval(kk).start > candidate.end
            fprintf('new area after,nstart %d, nend %d, oldstart %d, oldend %d\n',pinterval(kk).start, pinterval(kk).end, candidate.start, candidate.end);
            % new area found
            newarea(areacount).start = pinterval(kk).start;
            newarea(areacount).end = pinterval(kk).end;
            areacount = areacount + 1;
        elseif pinterval(kk).end > candidate.end;
            candidate.end = pinterval(kk).end;
        end  
    end

    %use the new obtained area for next iteration
    pinterval = newarea;
    newarea = [];

    %save the candidate
    parea(i).start = candidate.start;
    parea(i).end = candidate.end;
    parea(i).fstart = fpoints(candidate.start);
    parea(i).fend = fpoints(candidate.end);
    i = i + 1;

    fprintf('iterate again, new length %d\n', length(pinterval));
    pause
end
function output = extract_inertia(input, sensaxis)

output = struct('nodeid',[]);
for i=1:length(input)
    disp(strcat('processing data of:',input(i).name));
    tsample = input(i).tsample;
    fs = input(i).fs;

    %based on sensor setup
    node_num = [96,94,97,99,95,98];
    tempdata(1) = extract_data(input(i).data.node_96, fs, sensaxis);
    tempdata(2) = extract_data(input(i).data.node_94, fs, sensaxis);
    tempdata(3) = extract_data(input(i).data.node_97, fs, sensaxis);
    tempdata(4) = extract_data(input(i).data.node_99, fs, sensaxis);
    tempdata(5) = extract_data(input(i).data.node_95, fs, sensaxis);
    tempdata(6) = extract_data(input(i).data.node_98, fs, sensaxis);

    % for j=1:length(tempdata)
    %     tempdata(j).resvibdata = resample(tempdata(j).vibdata, tempdata(j).tstamp);
    % end

    %trimming the data first, set to shortest length and divisible by 16
    for j=1:length(tempdata)
        lendata(j) = length(tempdata(j).vibdata);
    end
    datalen = min(lendata);
    datalen = datalen - mod(datalen,16);

    for j=1:length(tempdata)
        output(i).nodeid(:,j) =  node_num(j);
        output(i).vibdata(:,j) = tempdata(j).vibdata(1:datalen);
        output(i).resvibdata(:,j) = resample(output(i).vibdata(:,j), tempdata(j).tstamp(1:datalen));
        output(i).tstamp(:,j) = tempdata(j).tstamp(1:datalen);
        output(i).misscount(:,j) = tempdata(j).misscount;
    end

    output(i).tsample = tsample;
    output(i).fs = fs;
    output(i).name = input(i).name;
    % output(i).data = tempdata;
end


%%%%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%
function nodedata = extract_data(node, fs, sensaxis)

tcol = node.columns.timestamp;

%choose the axis
if (sensaxis == 1)
    vibcol = node.columns.ax;
elseif (sensaxis == 2)
    vibcol = node.columns.ay;
else
    vibcol = node.columns.az;
end


tstamp(1) = node.data(1,tcol);
vibdata(1) = node.data(1,vibcol);
misscount = 0;

j=2;
for i=2:length(node.data)
    %need to convert to int, otherwise comparison wont work
    tdiff = int64((node.data(i,tcol) - tstamp(j-1))*fs);
    if tdiff ~= 1
        % fprintf('Missing count, previous : %0.3f, current : %0.3f, tdiff : %0.3f\n',tstamp(j-1),node.data(i,tcol),tdiff);
        % pause
        %a missing sample found
        for k=1:(tdiff-1)
            tstamp(j) = tstamp(j-1) + 1/fs;
            vibdata(j) = NaN;
            misscount = misscount + 1;
            j = j+1;
        end
    end

    tstamp(j) = node.data(i,tcol);
    vibdata(j) = node.data(i,vibcol);
    j = j+1;
end

fprintf('Original lenght %d, new length %d, new tstamp lenght %d, miss count %d\n',length(node.data),length(vibdata), length(tstamp),misscount);

nodedata = struct('tstamp', tstamp, 'vibdata', vibdata, 'resvibdata', [], 'misscount', misscount);
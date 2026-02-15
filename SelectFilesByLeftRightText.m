function dirSensorData = SelectFilesByLeftRightText(dirVolData,pattern)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    cnt = 0;
    for i = 1:length(dirVolData)
        startIndex = regexp(dirVolData(i).name,pattern,'tokens');

        if ~isempty(startIndex)
            periodMatch = str2num(cell2mat(startIndex{1}));

            cnt = cnt + 1;
            dirSensorData(cnt) = dirVolData(i);
            dirSensorData(cnt).datenum = periodMatch;
        end
    end
     
    if cnt ~= 0
        for i = 1:length(dirSensorData)
            [~,index] = sort([dirSensorData.datenum],'ascend');
            dirSensorData = dirSensorData(index);
        end
    else
        dirSensorData = [];
    end
end


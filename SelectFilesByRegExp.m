function [dirSensorData] = SelectFilesByRegExp(matchString,dirSensorData)
%SelectKeyFiles: 搜索指定路径下的文件,并且排序
% matchString：需要匹配的文件
% dirSensorData：指定路径下的结构体
dirSensorData = SelectFilesByMatchStr(matchString,dirSensorData);
%% 对文件按照日期进行排序
for i = 1:length(dirSensorData)
    [~,index] = sort([dirSensorData.volume],'ascend');
    dirSensorData = dirSensorData(index);
end

end

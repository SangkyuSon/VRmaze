function [data,dayIdx] = getPhysicalData(dataDir,subName)

idx = extractLowLevelFeatures(dataDir,subName);

foi = {'angSpdCorner','angConsistencyCorner','durationCorner','spdCorner','spdAfter',...
    'spdBefore','joyCorner','joyAfter','joyBefore','accCorner',...
    'accAfter','accBefore'};
dayIdx = struct2cell(idx);
dayIdx = cell2mat(dayIdx(strcmp(fieldnames(idx),'dayIdx'),:));
seldayIdx = find(sum(dayIdx==find(sum(dayIdx==(1:max(dayIdx))',2)>20)));
idx = idx(seldayIdx);

data = []; dayIdx = [];
for k = 1:length(idx),
    kdata = [];
    for fi = 1:length(foi),
        kdata = cat(2,kdata,idx(k).(foi{fi}));
    end
    data = cat(1,data,kdata);
    dayIdx = cat(1,dayIdx,repelem(idx(k).dayIdx,size(kdata,1),1));
end


end

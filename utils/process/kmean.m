function out = kmean(dataDir,subName)

fileName = sprintf('%s_kmean.mat',subName);
[isread,out] = dealFile(dataDir,fileName);
if ~isread

    [data,dayIdx] = getData(dataDir,subName);
    uniday = unique(dayIdx); dn = length(uniday);

    waring off
    cmax = 5;
    bootNo = 100;
    opt = statset('MaxIter',1e5,'TolFun',1e-15,'TolX',1e-15);
    last = 0;
    for c = 1:cmax,

        for d = 1:dn,
            
            clear dlab
            for bt = 1:bootNo,
                trsel = find(dayIdx~=uniday(d));
                tssel = find(dayIdx==uniday(d));

                trsel = trsel(ceil(rand(length(trsel),1)*length(trsel)));
                tssel = tssel(ceil(rand(length(tssel),1)*length(tssel)));
                
                trd = data(trsel,:);
                tsd = data(tssel,:);

                [~,cen] = kmeans(trd,c,'Options',opt,'Replicates',20);
                distClust = pdist2(cen,tsd,'euclidean');

                [withind,tslab] = min(distClust,[],1);
                within = nanmean(withind);

                tmp = distClust-withind;
                tmp(tmp==0) = nan;
                tmp = tmp+withind;

                across = nanmean(min(tmp,[],1));

                elbow(d,c,1,bt) = within;
                elbow(d,c,2,bt) = across;
                
                last = checkPerc(bootNo*dn*(cmax),bt+(d-1)*bootNo+(c-1)*bootNo*dn,last);
            end
        end
    end

    elbow = nanmean(elbow,4);

    clear data
    data.elbow = elbow;

    [isread,out] = dealFile(dataDir,fileName,'data',data);
end



end

function [data,dayIdx] = getData(dataDir,subName)

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

data = data./nanstd(data,[],1);

end

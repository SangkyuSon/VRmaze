function out = LNP_dataprep(dataDir,subName,ROI,cellIdx)

if nargin < 4, re = 1; else re = 0; end
outDir = fullfile(dataDir,'processed','LNP_prep');

if re,
    
    twinSz = 100;

    load(fullfile(dataDir,'raw',sprintf('%s_%s',subName,ROI)))
    
    start_end = zeros(length(bhv),4);
    for k = 1:length(bhv),start_end(k,:) = bhv{k}(end,7:10); end
    dayIdx = [1;cumsum(sum(diff(start_end(:,3:4),[],1),2)~=0)+1];
    seldayIdx = find(sum(dayIdx==find(sum(dayIdx==(1:max(dayIdx)),1)>20),2));
    
    psth = psth(seldayIdx);
    dayIdx = dayIdx(seldayIdx);
    bhv = bhv(seldayIdx);
    start_end = start_end(seldayIdx,:);
    
    [cx,cy,~,~,~,gx,gy,px,py] = getMapPos(0.1);    
    sg(1,:,:) = [gx,px;gy,py];
    sn = size(sg,3);
    if strcmp(subName,'P'), stateSeq = [1,2]; else stateSeq = [2,1];end
    boundDist = 3.5;

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    uniday = unique(dayIdx);dn = length(uniday); cnt = 0;
    for d = 1:dn,
        
        trIdx = find(dayIdx==uniday(d))';
        dpsth = []; dpos = [];
        for k = trIdx,
            kpos = bhv{k}(:,1:2);
            kpsth = psth{k}(:,end-length(kpos)+1:end);
            
            kpsth = kpsth(:,find(sum(kpos==start_end(k,1:2),2),1):end);
            kpos = kpos(find(sum(kpos==start_end(k,1:2),2),1):end,:)';

            jackWin = find(sum(kpos==kpos(1:2,end),1)==2,1):length(kpos);
            kpsth(:,jackWin) = [];
            kpos(:,jackWin) = [];

            spsth = movsum(kpsth,twinSz,2);
            spos = movmean(kpos,twinSz,2);

            dpsth = cat(2,dpsth,spsth(:,twinSz/2+1:twinSz:end));
            dpos = cat(2,dpos,spos(:,twinSz/2+1:twinSz:end));
        end

        for c = 1:size(dpsth,1),
            cnt = cnt + 1;

            data.psth = dpsth(c,:);
            data.pos = dpos;

            dealFile(outDir,sprintf('%s_%s_%d.mat',subName,ROI,cnt),'data',data);
        end
        
    end
else

    fileName = sprintf('%s_%s_%d.mat',subName,ROI,cellIdx);
    [~,out] = dealFile(outDir,fileName);
    
end

end
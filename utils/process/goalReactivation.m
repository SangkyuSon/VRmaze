function out = goalReactivation(dataDir,subName,ROI)

fileName = sprintf('%s_%s_goalReactivation.mat',subName,ROI);
[isread,out] = dealFile(dataDir,fileName);

if ~isread,

    sumd = frsummary_react(dataDir,subName,ROI);
    
    zfr = cellfun(@(x1) (x1-mean(x1,1))./std(x1,[],1),sumd.fr.corner,'un',0);
    jfr = cellfun(@(x1,x2) (x1-mean(x2,1))./std(x2,[],1),sumd.fr.jack,sumd.fr.corner,'un',0);

    [cx,cy,w,x,y,gx,gy,px,py] = getMapPos;
    sx = [gx,px]; sy = [gy,py];
    
    clear co coles
    for d = 1:size(zfr,2),
        for c = 1:size(zfr{d},1)
            
            cellNo = size(zfr{d},2);

            try, co{d}(c,1) = corr(zfr{d}(c,:)',jfr{d}(sumd.idx.trial{d}(c-1),:)','type','Spearman'); 
            catch, co{d}(c,1) = nan; end

            for ci = 1:cellNo,
                cisel = setdiff(1:cellNo,ci);
                try, coles{d}(c,ci) = corr(zfr{d}(c,cisel)',jfr{d}(sumd.idx.trial{d}(c-1),cisel)','type','Spearman'); catch, co{d}(c,1) = nan; end
            end

        end
    end

    clear data
    data.co = co;
    data.co_ablation = coles;
    data.idx = sumd.idx;
    
    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end
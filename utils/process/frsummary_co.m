function out = frsummary_co(dataDir,subName,ROI,re)

if nargin < 4, re = 0; end
outDir = fullfile(dataDir,'processed');
fileName = sprintf('%s_%s_%s.mat',subName,ROI,getCatName);
[isread,out] = dealFile(outDir,fileName);

if ~isread || re,

    sumd = frsummary_react(dataDir,subName,ROI);
    rsumdout = frsummary_reactRandom(dataDir,subName,ROI);
    rsumd = rsumdout.fr;
    %idx = frsummary_cellIdx(dataDir,subName,ROI);
    %idx = frsummary_cellIdxReg(dataDir,subName,ROI);
    idx = frsummary_cellIdxRegComb(dataDir,subName,ROI);

    zfr = cellfun(@(x1) (x1-mean(x1,1))./std(x1,[],1),sumd.fr.corner,'un',0);
    jfr = cellfun(@(x1,x2) (x1-mean(x2,1))./std(x2,[],1),sumd.fr.jack,sumd.fr.corner,'un',0);
    rfr = cellfun(@(x1,x2) (x1-mean(x2,1)')./std(x2,[],1)',rsumd,sumd.fr.corner,'un',0);
    sfr = cellfun(@(x1,x2) (x1-mean(x2,1)')./std(x2,[],1)',sumd.fr.subgoal,sumd.fr.corner,'un',0);

    [cx,cy,w,x,y,gx,gy,px,py] = getMapPos;
    sx = [gx,px]; sy = [gy,py];
    
    maxlen = size(rsumd{1},2);
    
    clear co rco srco sco coles
    for d = 1:size(zfr,2),
        for c = 1:size(zfr{d},1)
            
            cellNo = size(zfr{d},2);

            try, co{d}(c,1) = corr(zfr{d}(c,:)',jfr{d}(sumd.idx.trial{d}(c-1),:)','type','Spearman'); catch, co{d}(c,1) = nan; end
            
            for ci = 1:cellNo,
                cisel = setdiff(1:cellNo,ci);
                try, coles{d}(c,ci) = corr(zfr{d}(c,cisel)',jfr{d}(sumd.idx.trial{d}(c-1),cisel)','type','Spearman'); catch, co{d}(c,1) = nan; end
            end

            for dty = 1:5, 
                if dty <= 2, dtysel = idx.lb{d,dty} | idx.ub{d,dty};
                elseif dty==3, dtysel = (idx.lb{d,1} | idx.ub{d,1}) & ~(idx.lb{d,2} | idx.ub{d,2});
                elseif dty==4, dtysel = (idx.lb{d,2} | idx.ub{d,2}) & ~(idx.lb{d,1} | idx.ub{d,1});
                elseif dty==5, dtysel = (idx.lb{d,2} | idx.ub{d,2}) & (idx.lb{d,1} | idx.ub{d,1});
                end

                try, 
                    cosel{d}(c,dty,1) = corr(zfr{d}(c,dtysel)',jfr{d}(sumd.idx.trial{d}(c-1),dtysel)','type','Spearman'); 
                    cosel{d}(c,dty,2) = corr(zfr{d}(c,~dtysel)',jfr{d}(sumd.idx.trial{d}(c-1),~dtysel)','type','Spearman'); 
                catch, cosel{d}(c,dty,1:2) = nan; end
                
            end
            
            try,
                tmp = corr(rfr{d}(:,find(sum(rsumdout.trial{d}==(sumd.idx.trial{d}(c)+sum(cellfun(@max,sumd.idx.trial(1:d-1)))+(-10:10))',1))),jfr{d}(sumd.idx.trial{d}(c-1),:)','type','Spearman');
                rco{d}(c,:) = [tmp;nan(maxlen - length(tmp),1)];
            catch, rco{d}(c,:) = nan(1,size(rfr{d},2)); end
            
            try,
                lastIdx = zeros(1,7);
                for s = 1:7,
                    sl = find(~isnan(squeeze(sfr{d}(1,1:c-1,s))),1,'last');
                    if ~isempty(sl),lastIdx(s) = sl;end
                end
                [cIdx,sIdx] = max(lastIdx);
                sco{d}(c,1) = corr(sfr{d}(:,cIdx,sIdx),zfr{d}(c,:)','type','Spearman');
            catch,sco{d}(c,1) = nan; end
            
            try,
                tmp = corr(rfr{d}(:,find(sum(rsumdout.trial{d}==(sumd.idx.trial{d}(c)+sum(cellfun(@max,sumd.idx.trial(1:d-1)))+(-10:10))',1))),sfr{d}(:,cIdx,sIdx),'type','Spearman');
                srco{d}(c,:,1) = [tmp;nan(maxlen - length(tmp),1)];
            catch, srco{d}(c,:,1) = nan(1,size(rfr{d},2)); end

            try,
                cpos = [cx(sumd.idx.corner{d}(c));cy(sumd.idx.corner{d}(c))];
                [cIdx,sIdx] = sort(sum(abs([sx;sy]-cpos),1));
                cIdx = lastIdx(sIdx);
                sIdx(cIdx==0) = []; cIdx(cIdx==0) = [];
                cIdx = cIdx(1); sIdx = sIdx(1);
                sco{d}(c,2) = corr(sfr{d}(:,cIdx,sIdx),zfr{d}(c,:)','type','Spearman');
            catch, sco{d}(c,2) = nan; end

            try,
                tmp = corr(rfr{d}(:,find(sum(rsumdout.trial{d}==(sumd.idx.trial{d}(c)+sum(cellfun(@max,sumd.idx.trial(1:d-1)))+(-10:10))',1))),sfr{d}(:,cIdx,sIdx),'type','Spearman');
                srco{d}(c,:,2) = [tmp;nan(maxlen - length(tmp),1)];
            catch, srco{d}(c,:,2) = nan(1,size(rfr{d},2)); end
        end
    end

    clear data
    data.co = co;
    data.coles = coles;
    data.btco = rco;
    data.sco = sco;
    data.btsco = srco;
    data.cosel = cosel;
    data.idx = sumd.idx;
    data.idx.btIdx = rsumdout.idx;
    data.idx.jDist = rsumdout.dist;
    data.idx.cellSel = idx;

    [isread,out] = dealFile(outDir,fileName,'data',data);
end

end
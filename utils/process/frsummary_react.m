function out = frsummary_react(dataDir,subName,ROI,re)

if nargin < 4, re = 0; end
outDir = fullfile(dataDir);
fileName = sprintf('%s_%s_%s.mat',subName,ROI,getCatName);
[isread,out] = dealFile(outDir,fileName);

if ~isread || re,
    
    load(fullfile(dataDir,'raw',sprintf('%s_%s',subName,ROI)))
    
    start_end = zeros(length(bhv),4);
    for k = 1:length(bhv),start_end(k,:) = bhv{k}(end,7:10); end
    dayIdx = [1;cumsum(sum(diff(start_end(:,3:4),[],1),2)~=0)+1];
    seldayIdx = find(sum(dayIdx==find(sum(dayIdx==(1:max(dayIdx)),1)>20),2));
    
    psth = psth(seldayIdx);
    dayIdx = dayIdx(seldayIdx);
    bhv = bhv(seldayIdx);
    start_end = start_end(seldayIdx,:);
   
    hmmout = hmm8(dataDir,subName);
    
    [cx,cy,~,~,~,gx,gy,px,py] = getMapPos(0.1);    
    sg(1,:,:) = [gx,px;gy,py];
    sn = size(sg,3);
    if strcmp(subName,'P'), stateSeq = [1,2]; else stateSeq = [2,1];end
    boundDist = 3.5;

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    uniday = unique(dayIdx);dn = length(uniday);
    maxcn = 0;
    for d = 1:dn,
        trIdx = find(dayIdx==uniday(d))';
 
        clear initFr jackFr initPos cfr cpos cd2x cd2y cstate trial corfr error sfr corIdx cprob copt
        kcnt = 0; ccnt = 0;
        for k = trIdx,

            kcnt = kcnt + 1; 
            
            kpos = bhv{k}(:,1:2);
            kpsth = psth{k}(:,end-length(kpos)+1:end);
            
            kpsth = kpsth(:,find(sum(kpos==start_end(k,1:2),2),1):end);
            kpos = kpos(find(sum(kpos==start_end(k,1:2),2),1):end,:);

            jackWin = find(sum(kpos==kpos(end,1:2),2)==2,1):length(kpos);
            jackFr(kcnt,:) = mean(kpsth(:,jackWin),2)*1e3;
        
            [corBgn,cIdx,cn] = findCorner(kpos,sqrt(2)*1.5);
            [nCell,maxnT] = size(kpsth);
            sIdx = squeeze(sqrt(sum((kpos-sg).^2,2)) < boundDist);

            for c = 1:cn,
                
                ccnt = ccnt + 1;
                cwin = corBgn(c,1):corBgn(c,2);
                cwin(cwin<1 | cwin>maxnT) = [];

                cfr(ccnt,:) = mean(kpsth(:,cwin),2)*1e3;

                try,
                    corwin = corBgn(c,2):corBgn(c+1,1);
                    corfr(ccnt,:) = mean(kpsth(:,corwin),2)*1e3;
                    corIdx(ccnt,:) = round(mean(kpos(corwin,:)+28,1)./7);
                catch
                    corfr(ccnt,:) = nan(nCell,1);
                    corIdx(ccnt,:) = nan;
                end

                try,
                    ccwin = corBgn(c,1):corBgn(c+1,1);
                    for s = 1:sn,
                        swin = ccwin(sIdx(ccwin,s));
                        if ~isempty(swin), sfr(:,ccnt,s) = mean(kpsth(:,swin),2)*1e3;
                        else, sfr(:,ccnt,s) = nan(nCell,1); end
                    end
                catch,
                    sfr(:,ccnt,:) = nan(nCell,sn);
                end

                behWin = (c-maxcn):(c+maxcn);

                prevBeh = nan(sum(behWin<1),1);
                aftBeh = nan(sum(behWin>cn),1);
                behWin(behWin<1 | behWin>cn) = [];

                cpos(ccnt,:) = [prevBeh;cIdx(behWin);aftBeh];
                cd2x(ccnt,:) = [prevBeh;(cx(cIdx(behWin))'-start_end(k,3));aftBeh];
                cd2y(ccnt,:) = [prevBeh;(cy(cIdx(behWin))'-start_end(k,4));aftBeh];
                cstate(ccnt,:) = [prevBeh;stateSeq(hmmout(k).state(behWin))';aftBeh];
                error(ccnt,:) = [prevBeh;hmmout(k).error(behWin,4);aftBeh];
                cprob(ccnt,:) = hmmout(k).probBeenThereSelNorm(behWin);
                trial(ccnt,1) = kcnt;

                copt(ccnt,1:4) = nan;
                pds = [+1,0;0,+1;-1,0;0,-1];
                for pd = 1:size(pds,1),
                    tmp = find(sum(sum([cx;cy]' == permute( [cx(hmmout(k).cIdx(c)),cy(hmmout(k).cIdx(c))]+pds(pd,:)*14 , [3,2,1]),2)==2,3));
                    if ~isempty(tmp), copt(ccnt,pd) = hmmout(k).probAll(c,tmp); end
                end

            end
        end

        data.fr.jack{d} = jackFr;
        data.fr.corner{d} = cfr;
        data.fr.corridor{d} = corfr;
        data.fr.subgoal{d} = sfr;
        
        data.idx.corIdx{d} = corIdx;
        data.idx.corner{d} = cpos;
        data.idx.d2x{d} = cd2x;
        data.idx.d2y{d} = cd2y;
        data.idx.state{d} = cstate;
        data.idx.jackpot{d} = start_end(k,3:4);
        data.idx.trial{d} = trial;
        data.idx.cIdx = maxcn;
        data.idx.error{d} = error;
        data.idx.prob{d} = cprob;
        data.idx.optProb{d} = copt;

    end
    
    [isread,out] = dealFile(outDir,fileName,'data',data);
end

end
function [chgPathRe,optComp,infComp] = revisitComparison(dataDir,subj,ROI)

for m = 1:2,
    circ = summaryLowLevelFeatures(dataDir,subj{m});
    circ.info = cellfun(@(x1) transferVal(x1,Inf,30),circ.info,'un',0);

    comap = pathReactivation(dataDir,subj{m},ROI);
    origMap = cellfun(@(x1) cat(3,nan(size(x1,1),9,1),cat(2,nan(size(x1,1),1,7),x1,nan(size(x1,1),1,7)),nan(size(x1,1),9,1)),comap.origMap,'un',0);

    [cx,cy] = getMapPos;
    pcho = [1,0;0,1;-1,0;0,-1];
    
    clear prevState curState bcr acr opt anr bnr info copt cinfo pinfo 
    for d = 1:length(origMap),
        for c = 1:length(origMap{d}),
            curIdx = find(comap.idx.corner{d}(c)==comap.idx.corner{d}(c+1:end),1)+c;
            

            try,
                prevState{d}(c) = comap.idx.state{d}(c);
                curState{d}(c) = comap.idx.state{d}(curIdx);
                
                cpos = comap.idx.corner{d}(curIdx);
                x = ((cx(cpos)+35)/14)*2;
                y = ((cy(cpos)+35)/14)*2;
                xwin = x+[-1:1];
                ywin = y+[-1:1];


                cdor = squeeze(origMap{d}(curIdx,ywin,xwin));
                cdor(cdor==origMap{d}(curIdx,y,x)) = nan;

                pdor = squeeze(origMap{d}(c,ywin,xwin));
                pdor(pdor==origMap{d}(c,y,x)) = nan;

                precChoice = find(circ.oopt{d}(c,:)==circ.opt{d}(c),1);
                bcr{d}(c) = nanmean([origMap{d}(c,y+pcho(precChoice,2),x+pcho(precChoice,1)),origMap{d}(c,y+pcho(precChoice,2)*2,x+pcho(precChoice,1)*2)]);
                acr{d}(c) = nanmean([origMap{d}(curIdx,y+pcho(precChoice,2),x+pcho(precChoice,1)),origMap{d}(curIdx,y+pcho(precChoice,2)*2,x+pcho(precChoice,1)*2)]);

                bnr{d}(c) = nanmean(pdor(pdor~=origMap{d}(c,y+pcho(precChoice,2),x+pcho(precChoice,1)) & pdor~=origMap{d}(c,y+pcho(precChoice,2)*2,x+pcho(precChoice,1)*2)));
                anr{d}(c) = nanmean(cdor(cdor~=origMap{d}(curIdx,y+pcho(precChoice,2),x+pcho(precChoice,1)) & cdor~=origMap{d}(curIdx,y+pcho(precChoice,2)*2,x+pcho(precChoice,1)*2)));

                opt{d}(c) = circ.opt{d}(c);
                copt{d}(c) = circ.opt{d}(curIdx);
                info{d}(c) = circ.info{d}(c);

                pinfo{d}(c) = (circ.info{d}(c)~=max(circ.oinfo{d}(c,:)))*1;

                cinfo{d}(c) = circ.info{d}(curIdx);

            catch,
                prevState{d}(c) = nan;
                curState{d}(c) = nan;
                bcr{d}(c) = nan;
                acr{d}(c) = nan;
                bnr{d}(c) = nan;
                anr{d}(c) = nan;
                opt{d}(c) = nan;
                info{d}(c) = nan;
                copt{d}(c) = nan;
                cinfo{d}(c) = nan;
                pinfo{d}(c) = nan;
            end
        end
    end

    for h = 1:2,
        for q = 1:4,
            if h == 1,
                if q == 1,    idx = cellfun(@(x1,x2,x3) x1==1 & x3==1,prevState,curState,pinfo,'un',0);
                elseif q == 2,idx = cellfun(@(x1,x2,x3) x1==1 & x3~=1,prevState,curState,pinfo,'un',0);
                elseif q == 3,idx = cellfun(@(x1,x2,x3) x1==1 & x3<0.5,prevState,curState,opt,'un',0);
                elseif q == 4,idx = cellfun(@(x1,x2,x3) x1==1 & x3>0.5,prevState,curState,opt,'un',0); end
            elseif h == 2,
                if q == 1,    idx = cellfun(@(x1,x2,x3) x1==2 & x3==1,prevState,curState,pinfo,'un',0);
                elseif q == 2,idx = cellfun(@(x1,x2,x3) x1==2 & x3~=1,prevState,curState,pinfo,'un',0);
                elseif q == 3,idx = cellfun(@(x1,x2,x3) x1==2 & x3<0.5,prevState,curState,opt,'un',0);
                elseif q == 4,idx = cellfun(@(x1,x2,x3) x1==2 & x3>0.5,prevState,curState,opt,'un',0); end
            end

            cpr{m}(:,q+(h-1)*4) = cellfun(@(x1,x2,x3,x4,x5) ((nanmean(x1(x5))-nanmean(x2(x5)))-(nanmean(x3(x5))-nanmean(x4(x5))))./abs(nanmean(x3(x5)))*100,acr,anr,bcr,bnr,idx);
            mopt{m}(:,q+(h-1)*4) = cellfun(@(x1,x2) nanmean(x1(x2)),copt,idx);
            minf{m}(:,q+(h-1)*4) = cellfun(@(x1,x2) nanmean(x1(x2)),cinfo,idx);

        end
    end
end

chgPathRe = cell2mat(cpr');
optComp = cell2mat(mopt');
infComp = cell2mat(minf');

chgPathRe = chgPathRe(:,[1,2,7,8]);
optComp = optComp(:,5:8)*100;
infComp = infComp(:,1:4);

end
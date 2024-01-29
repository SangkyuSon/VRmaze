function out = pathReactivation(dataDir,subName,ROI)


fileName = sprintf('%s_%s_pathReactivation.mat',subName,ROI);,
[isread,out] = dealFile(dataDir,fileName);

if ~isread,

    twin = (-100:100);
    sumd = frsummary_react(dataDir,subName,ROI);
    circ = summaryLowLevelFeatures(dataDir,subName);
    
    zfr = cellfun(@(x1) (x1-mean(x1,1))./std(x1,[],1),sumd.fr.corner,'un',0);
    cfr = cellfun(@(x1,x2) (x1-mean(x2,1))./std(x2,[],1),sumd.fr.corridor,sumd.fr.corner,'un',0);
    [cx,cy] = getMapPos;
    
    for d = 1:size(sumd.fr.corner,2),

        fr = zfr{d};
        dc = cfr{d};

        cIdx = sumd.idx.corner{d};
        corIdx = sumd.idx.corIdx{d};
        state = sumd.idx.state{d};
        cn = size(fr,1);

        comap = nan(cn,7,7);
        for c = 1:cn,
            cwin = twin+c;
            cwin = cwin(cwin>0);
            cwin = cwin(cwin<=cn);

            coval = corr(fr(cwin,:)',fr(c,:)','type','Spearman');
            ccoval = corr(dc(cwin,:)',fr(c,:)','type','Spearman');

            ccomap = nan(7,7);
            for ci = 1:14,
                ciidx = ([(cx(ci)+35)/14,(cy(ci)+35)/14]-1)*2+1;
                ccomap(ciidx(1),ciidx(2)) = nanmean(coval(cIdx(cwin)==ci));
            end

            for x = 1:7,
                for y = 1:7,
                    tmp = nanmean(ccoval(sum(corIdx(cwin,:)==[x,y],2)==2));
                    if ~(mod(x,2)==1 & mod(y,2)==1), ccomap(x,y) = tmp; end
                end
            end

            comap(c,:,:) = ccomap';
        end

        nn = 21;
        enlarge = 5;
        cmap = nan(cn,nn,nn);
        prv = nan(cn,2);
        for c = 1:cn,
            kmap = squeeze(comap(c,:,:));
            cpos = [(cx(sumd.idx.corner{d}(c))+35)/7,(cy(sumd.idx.corner{d}(c))+35)/7]-1;

            init = ceil(nn/2)-cpos;
            for x = 1:7,
                for y = 1:7,
                    cmap(c,x+init(2),y+init(1)) = kmap(x,y);
                end
            end

         
            try,
                prevpos = [(cx(sumd.idx.corner{d}(c-1))+35)/7,(cy(sumd.idx.corner{d}(c-1))+35)/7]-1;
                npos = [(cx(sumd.idx.corner{d}(c+1))+35)/7,(cy(sumd.idx.corner{d}(c+1))+35)/7]-1;
                
                prv(c,:) = [kmap(prevpos(1),prevpos(2)),kmap((prevpos(1)+cpos(1))/2,(prevpos(2)+cpos(2))/2)];
                
            catch,
                prv(c,:) = nan;
            end
        end

        jmap = nan(cn,nn,nn);
        jrmap = nan(cn,nn,nn);
        for c = 1:cn,
            kmap = squeeze(comap(c,:,:));

            jpos = round((sumd.idx.jackpot{d}+35)/7)-1;
            jpos(jpos<1) = 1;
            cpos = jpos;

            init = ceil(nn/2)-cpos;
            for x = 1:7,
                for y = 1:7,
                    jmap(c,x+init(2),y+init(1)) = kmap(x,y);
                end
            end

            jpos = ((sumd.idx.jackpot{d}+35)/7)-1;
            cpos = [(cx(sumd.idx.corner{d}(c))+35)/7,(cy(sumd.idx.corner{d}(c))+35)/7]-1;

            ppos = jpos + [+1,0;0,+1;-1,0;0,-1]*2;
            [~,sortIdx] = sort(sum(abs(ppos-cpos),2));

            rotAng = atan2d(jpos(2)-cpos(2),jpos(1)-cpos(1))+90;
            tmp = imrotate(imresize(squeeze(jmap(c,:,:)),enlarge,'nearest'),rotAng,'nearest','crop');
            tmp(tmp==0) = nan;
            jrmap(c,:,:) = imresize(tmp,1/enlarge,'nearest');
        end

        
        data.origMap{d} = comap;
        data.pastPath{d} = prv;
        data.pathMap{d} = jrmap;
        
        data.state{d} = state;
        data.idx = sumd.idx;
    end

    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end
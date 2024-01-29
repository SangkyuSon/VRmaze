function drawFigure2D(dataDir,subj,rois)


nf;
condNames = {'Explore-like','Exploit-like',sprintf('Exploit-like\n(Not optimal)')};

for r = 1:2,
    for m = 1:2,
        out = pathReactivation(dataDir,subj{m},rois{r});
        
        cutSz = 0;
        cutWin = (1+cutSz):(21-cutSz);
        cn = length(cutWin);

        data2use = cellfun(@(x1) x1(:,cutWin,cutWin),out.pathMap,'un',0);


        for h = 1:3,
            if h == 1, 
                data{h,m} = permute(cell2mat(cellfun(@(x1,x2,x3) permute(nanmean(x1(x2==1 & x3<0.5,:,:),1),[2,1,3]),data2use,out.state,out.idx.error,'un',0)),[2,1,3]);
            elseif h == 2,
                data{h,m} = permute(cell2mat(cellfun(@(x1,x2,x3) permute(nanmean(x1(x2==2 & x3<0.5,:,:),1),[2,1,3]),data2use,out.state,out.idx.error,'un',0)),[2,1,3]);
            elseif h == 3,
                data{h,m} = permute(cell2mat(cellfun(@(x1,x2,x3) permute(nanmean(x1(x2==2 & x3>0.5,:,:),1),[2,1,3]),data2use,out.state,out.idx.error,'un',0)),[2,1,3]);
            end
        end

    end

    for h = 1:3,
        subplot(2,3,h+(r-1)*3)
        dataAll = permute(cell2mat(cellfun(@(x1) permute(x1,[2,1,3]),data(h,:),'un',0)),[2,1,3]);
        heatmap(dataAll,1:cn,1:cn);
        ylim([ceil(cn/2)+0.5,ceil(cn/2)+6.5])
        xlim([-1,1]*6.5+ceil(cn/2))
        set(gca,'ydir','reverse')
        caxis([0,0.3])
        axis off
        daspect([1,0.5,1])
        
        title(sprintf('%s\n%s',rois{r},condNames{h}))
       
    end
end



end

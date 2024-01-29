function drawFigure2E(dataDir,subj,rois)


nf;
for r = 1:2,
    dsv = [];
    for m = 1:2,
        out = pathReactivation(dataDir,subj{m},rois{r});
        data2use = out.pastPath;

        clear pdiff
        for h = 1:3,

            if h==1,
                pdiff(:,h) = cellfun(@(x1,x2,x3) mean(nanmean(x1(x2==1 & x3<0.5,:),1),2),data2use,out.state,out.idx.error,'un',1);
            elseif h==2,
                pdiff(:,h) = cellfun(@(x1,x2,x3) mean(nanmean(x1(x2==2 & x3<0.5,:),1),2),data2use,out.state,out.idx.error,'un',1);
            elseif h==3,
                pdiff(:,h) = cellfun(@(x1,x2,x3) mean(nanmean(x1(x2==2 & x3>0.5,:),1),2),data2use,out.state,out.idx.error,'un',1);
            end
        end


        dsv = [dsv;pdiff];
    end
    
    subplot(1,2,r)
    bar_custom(dsv,'errorbar',1)
    title(rois{r})
    xticklabels({'Explore-like','Exploit-like','Exploit-like (Not optimal)'})
    ylabel('Past path reactivation (rho)')

end
end

function drawFigure2G(dataDir,subj,rois)

nf; 
for r = 1:2,
    adata= [];
    for m = 1:2,
        out = goalReactivation(dataDir,subj{m},rois{r});
        cellProp = cellProperty(dataDir,subj{m},rois{r});
        
        corat = cellfun(@(x1,x2) nanmean(x1-x2,1),out.co_ablation,out.co,'un',0);
        infoIdx = cellfun(@(x1,x2) x1 | x2, cellProp.lb(:,1)', cellProp.ub(:,1)','un',0);
        optIdx = cellfun(@(x1,x2) x1 | x2, cellProp.lb(:,2)', cellProp.ub(:,2)','un',0);
                
        ddata = [...
            cellfun(@(x1,x2) nanmean(x2(x1<0)*1), corat,infoIdx)',...
            cellfun(@(x1,x2) nanmean(x2(x1<0)*1), corat,optIdx)'];
        
        adata = [adata;ddata];
    end
    
    
    
    subplot(1,2,r)
    bar_custom(adata*100,'errorbar',1)
    xticklabels({'info. selective','Goal selective'})
    ylabel(sprintf('Cell proportion of \nincreasing reactivation'))
    title(rois{r})
end


end

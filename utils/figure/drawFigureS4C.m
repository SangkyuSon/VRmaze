function drawFigureS4C(dataDir,subj,rois)

featureName = {'x-coord.','y-coord.','Head direction','Speed'};
nf
for m = 1:2,
    for r = 1:2,
        
        out = LNP(dataDir,subj{m},rois{r});

        for i = 1:4,
            val = out.rsq(:,i);
            dist = squeeze(out.rsq_pm(:,i,:));

            subplot(4,4,i+((m+(r-1)*2)-1)*4)
            histogram(dist(:),linspace(-1,1,100),'Normalization','probability','FaceColor',[1,1,1]*0.7,'EdgeAlpha',0)
            xlim([-1,1])
            hold on
            line([1,1]*nanmean(val),[0,0.01],'Color',[1,1,1]*0)
            if i==2 & m == 2 & r == 2, xlabel('R-square of model over true tuning'); end

            if m == 1 & r == 1, title(featureName{i}); end
            if i == 1, ylabel(sprintf('%s,%s',rois{r},subj{m})); end
        end
        
    end
end


end



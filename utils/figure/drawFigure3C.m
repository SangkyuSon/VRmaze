function drawFigure3C(dataDir,subj,rois)

ylimval = [-1,1]*40;

condNames = {sprintf('Previous visit\nExplore-like'),sprintf('Previous visit\nExploit-like')};
nf
for r = 1:2,
    [chgPathRe,~,~] = revisitComparison(dataDir,subj,rois{r});
    
    subplot(1,4,1+(r-1)*2)
    bar_custom(chgPathRe(:,1:2))
    xticklabels({'Not-informative','Informative'})
    ylim(ylimval)
    title(sprintf('%s\n(%s)',condNames{1},rois{r}))

    subplot(1,4,2+(r-1)*2)
    bar_custom(chgPathRe(:,3:4))
    xticklabels({'Not-optimal','Optimal'})
    ylim(ylimval)
    title(sprintf('%s\n(%s)',condNames{2},rois{r}))
end

end



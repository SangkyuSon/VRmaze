function drawFigureS5(dataDir,subj)

[~,optComp,infComp] = revisitComparison(dataDir,subj,'RSC');

infLim = [1.3,3.3];
optLim = [40,100];

nf;
subplot(1,2,1)
scatter(infComp(:,3),infComp(:,4),10,[1,1,1]*0,'filled','o','MarkerFaceAlpha',0.6)
xlim(infLim)
ylim(infLim)
line(infLim,infLim,'Color',[1,1,1]*0.7,'LineStyle','--')
axis square
xlabel(sprintf('After not-optimal choice\n(current info.; %)'))
ylabel(sprintf('After optimal choice\n(current info.; %)'))
title(sprintf('Previous visit\nExplore-like'))

subplot(1,2,2)
scatter(optComp(:,1),optComp(:,2),10,[1,1,1]*0,'filled','o','MarkerFaceAlpha',0.6)
xlim(optLim)
ylim(optLim)
line(optLim,optLim,'Color',[1,1,1]*0.7,'LineStyle','--')
axis square
xlabel(sprintf('After not-informative\nchoice (current optimality.; bit)'))
ylabel(sprintf('After informative\nchoice (current optimality.; bit)'))
title(sprintf('Previous visit\nExploit-like'))

end



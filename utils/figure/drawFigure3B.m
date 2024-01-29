function drawFigure3B(dataDir,subj)

[~,optComp,infComp] = revisitComparison(dataDir,subj,'RSC');

infLim = [1.3,2.7];
optLim = [10,90];

nf;
subplot(1,2,1)
xbar_custom(infComp(:,1),infComp(:,2))
xlim(infLim)
ylim(infLim)
line(infLim,infLim,'Color',[1,1,1]*0.7,'LineStyle','--')
axis square
xlabel(sprintf('After not-informative\nchoice (current info.; bit)'))
ylabel(sprintf('After informative\nchoice (current info.; bit)'))
title(sprintf('Previous visit\nExplore-like'))

subplot(1,2,2)
xbar_custom(optComp(:,3),optComp(:,4))
xlim(optLim)
ylim(optLim)
line(optLim,optLim,'Color',[1,1,1]*0.7,'LineStyle','--')
axis square
xlabel(sprintf('After not-optimal choice\n(current optimality.; %)'))
ylabel(sprintf('After optimal choice\n(current optimality.; %)'))
title(sprintf('Previous visit\nExploit-like'))

end



function drawFigure1H(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};

clear rankProb orankProb
for m = 1:2,
    out = summaryLowLevelFeatures(dataDir,subj{m});
    
    rankProb{m} = cell2mat(cellfun(@(x1,x2,x3,x4) mean((x1(x2==1 & x3')==(1:4)),1),out.irank,out.state,out.yesChoice,out.oinfo,'un',0)');
    orankProb{m} = cell2mat(cellfun(@(x1,x2,x3,x4) mean((x1(x2==2 & x3')==(1:4)),1),out.orank,out.state,out.yesChoice,out.oinfo,'un',0)');

end

nf;
subplot(1,2,1)
bar_custom(cell2mat(rankProb'),'errorbar',1,'LineColor',condCols{1})
line([0.5,4.5],[0.25,0.25],'Color',[1,1,1]*0.7,'LineStyle','--')
xlabel(sprintf('Info. level\nof path'))
ylabel(sprintf('Proportion of choices'))

subplot(1,2,2)
bar_custom(cell2mat(orankProb'),'errorbar',1,'LineColor',condCols{2})
line([0.5,4.5],[0.25,0.25],'Color',[1,1,1]*0.7,'LineStyle','--')
xlabel(sprintf('Optimal level\nof path'))

end
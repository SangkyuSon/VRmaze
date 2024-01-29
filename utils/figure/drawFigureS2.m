function drawFigureS2(dataDir,subj)

for m = 1:2,
    out = summaryLowLevelFeatures(dataDir,subj{m});

    x{m} = cellfun(@(x1,x2) mean(mean(x1(x2==1,:),2),1),out.oopt,out.state,'un',1)*100;
    y{m} = cellfun(@(x1,x2) mean(x1(x2==1)),out.opt,out.state,'un',1)*100;

end

nf
xbar_custom(cell2mat(x),cell2mat(y))
line([20,80],[20,80],'Color',[1,1,1]*0.7,'LineStyle','--')
xlabel(sprintf('Choice optimality\nin random walk (%%)'))
ylabel(sprintf('Choice optimality\nin exploit-like state (%%)'))

end


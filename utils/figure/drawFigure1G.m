function drawFigure1G(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};

for m = 1:2,

    out = summaryLowLevelFeatures(dataDir,subj{m});
    out.info = cellfun(@(x1) transferVal(x1,x1==Inf,30),out.info,'un',0);
    
    
    for h = 1:2,
        opt{m,h} = cellfun(@(x1,x2) (x1(x2==h)),out.opt,out.state,'un',0);
        info{m,h} = cellfun(@(x1,x2) (x1(x2==h)),out.info,out.state,'un',0);
    end
end

clear val
for h = 1:2,
    val{h}(:,1) = cell2mat(cellfun(@(x1) cellfun(@nanmean,x1),opt(:,h)','un',0))*100;
    val{h}(:,2) = cell2mat(cellfun(@(x1) cellfun(@nanmean,x1),info(:,h)','un',0));
end

nf
hold on;
cellfun(@(x1,x2) xbar_custom(x1(:,1),x1(:,2),'Color',x2,'scatter',1,'scatterColor',x2),val,condCols);
xlim([50,90])
ylim([1.5,3])
xlabel(sprintf('Percent of\noptimal choice (%%)'))
ylabel(sprintf('Earned information\nfrom choice (bit)'))

end

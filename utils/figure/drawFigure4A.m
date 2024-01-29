function drawFigure4A(dataDir,subj,rois)

for m = 1:2,
    RSC = goalReactivation(dataDir,subj{m},rois{1});
    OFC = goalReactivation(dataDir,subj{m},rois{2});

    x{m} = cell2mat(RSC.co');
    y{m} = cell2mat(OFC.co');
    co{m} = cellfun(@(x1,x2) corr(x1,x2,'type','Spearman','rows','pairwise'),RSC.co,OFC.co);

end

X = cell2mat(x');
Y = cell2mat(y');

scatter(X,Y,10,[1,1,1]*0,'filled','o','MarkerFaceAlpha',0.2)
hold on;
Y(isinf(Y)) = nan;
coef = glmfit(X,Y,'normal');
plot(linspace(min(X),max(X),100),linspace(min(X),max(X),100)*coef(2)+coef(1),'Color',[1,1,1]*0)
xlabel(sprintf('RSC goal\nreactivation (rho)'))
ylabel(sprintf('OFC goal\nreactivation (rho)'))
text(-0.4,0.8,sprintf('rho = %.3f',mean(cell2mat(co))))

end



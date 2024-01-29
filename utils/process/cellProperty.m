function out = cellProperty(dataDir,subName,ROI)


fileName = sprintf('%s_%s_cellProperty.mat',subName,ROI);
[isread,out] = dealFile(dataDir,fileName);

if ~isread,

    bootNo = 1e2*3;
    out = frsummary_react(dataDir,subName,ROI);

    % information selective cell
    Y = cellfun(@(x1) log2(1./x1),out.idx.prob,'un',0);  % information
    co_info = measureCoeff(out.fr.corner,Y);
    for bt = 1:bootNo,
        btY = cellfun(@(x1) x1(randperm(length(x1))),Y,'un',0);
        btco_i(:,bt) = measureCoeff(out.fr.corner,btY);
    end
    for d = 1:size(btco_i,1), btdist_i{d} = cell2mat(btco_i(d,:)'); end

    lb(:,1) = cellfun(@(x1,x2) x1 <= prctile(x2,2.5,1),co_info,btdist_i,'un',0);
    ub(:,1) = cellfun(@(x1,x2) x1 >= prctile(x2,97.5,1),co_info,btdist_i,'un',0);

    % goal selective cell
    mfr = cellfun(@(x1) mean(x1,1),out.fr.jack,'un',0);
    for bt = 1:bootNo, bfr(:,bt) = cellfun(@(x1) mean(x1(ceil(rand(1,size(x1,1))*size(x1,1)),:),1),out.fr.corner,'un',0); end
    for d = 1:size(bfr,1), btdist{d} = cell2mat(bfr(d,:)'); end
    lb(:,2) = cellfun(@(x1,x2) x1 < prctile(x2,2.5,1),mfr,btdist,'un',0);
    ub(:,2) = cellfun(@(x1,x2) x1 > prctile(x2,97.5,1),mfr,btdist,'un',0);

    data.lb = lb;
    data.ub = ub;

    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end

function coef = measureCoeff(neural,beh)

cellsplit = cellfun(@(x1) mat2cell(x1,size(x1,1),ones(size(x1,2),1)),neural,'un',0);
coef = cellfun(@(x1,x2) cellfun(@(x3) glmfit(x2(x2~=Inf),x3(x2~=Inf),'normal','Constant','on'),x1,'un',0),cellsplit,beh,'un',0);
coef = cellfun(@(x1) cell2mat(x1),coef,'un',0);
coef = cellfun(@(x1) x1(2,:),coef,'un',0);

end

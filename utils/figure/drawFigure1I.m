function drawFigure1I(dataDir,subj)

allrat = [];
for m = 1:2,
    out = hmm(dataDir,subj{m});
    
    outCell = squeeze(struct2cell(out));

    dayIdx = cell2mat(outCell(strcmp(fieldnames(out),'dayIdx'),:));
    dayIdx = repelem(dayIdx,cellfun(@length,outCell(strcmp(fieldnames(out),'cIdx'),:))); 
    uniday = unique(dayIdx); dn = length(uniday);
    daycum = cumsum(dayIdx==unique(dayIdx)',2);
    daycum(boolean([zeros(size(daycum,1),1),diff(daycum,[],2)==0])) = nan;
    dayrat = nansum(daycum./max(daycum,[],2),1);

    state = (cell2mat(outCell(strcmp(fieldnames(out),'state'),:))); 
    opt = 1-cell2mat(cellfun(@(x1) x1(2:end,4),outCell(strcmp(fieldnames(out),'error'),:),'un',0)');

    clear rat
    for d = 1:dn,
        trsel = cell2mat(outCell(strcmp(fieldnames(out),'dayIdx'),:))==uniday(d);
        tmp = cellfun(@(x1) mean((x1))-1,outCell(strcmp(fieldnames(out),'state'),trsel));
        rat(d,:) = tmp(1:50);
    end
    
    allrat = [allrat;rat];

end
data = movmean(1-allrat,20,2);
nf;
shadedplot_custom(data)
xlabel('Trial number')
ylabel(sprintf('Proportion of exploit-like state (%%)'))
end
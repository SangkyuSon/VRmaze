function drawFigure1C(dataDir,subj)

atime =[]; aopt = []; acor = [];aent = [];
filtWin = 10;
for m = 1:2,
    out = hmm(dataDir,subj{m});
    
    outCell = struct2cell(out);
    timeLeft = outCell(strcmp(fieldnames(out),'timeLeft'),:);
    timeLeft = cellfun(@(x1) x1(1),timeLeft)./1e3;
    opt = outCell(strcmp(fieldnames(out),'error'),:);
    opt = 1-cellfun(@(x1) nanmean(x1(:,4),1),opt);
    corner = cellfun(@length,outCell(strcmp(fieldnames(out),'cIdx'),:));
    dayIdx = cell2mat(outCell(strcmp(fieldnames(out),'dayIdx'),:));
    uniday = unique(dayIdx); dn = length(uniday);

    clear dTime dOpt dCor 
    for d = 1:dn,
        dIdx = dayIdx==uniday(d);
        tmp = timeLeft(dIdx);
        dTime(d,:) = tmp(1:50);

        tmp = opt(dIdx);
        dOpt(d,:) = tmp(1:50);
        
        tmp = corner(dIdx);
        dCor(d,:) = tmp(1:50);

    end
    atime = [atime;dTime];
    aopt = [aopt;dOpt];
    acor = [acor;dCor];
end

nf
subplot(1,3,1)
shadedplot_custom(movmean(atime,filtWin,2))
ylabel('Search time (s)')

subplot(1,3,2)
shadedplot_custom(movmean(acor,filtWin,2))
xlabel('Trial number')
ylabel('Searched junctions')

subplot(1,3,3)
shadedplot_custom(movmean(aopt,filtWin,2))
ylabel('% of optimal choice')

end

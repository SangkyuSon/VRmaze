function drawFigure1F(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};

clear val
for m = 1:2,
    out = hmm(dataDir,subj{m});
    outCell = squeeze(struct2cell(out));

    poi = {'spdCorner','angConsistencyCorner','durationCorner','joyAfter'};
    pn = length(poi);

    dayIdx = cell2mat(outCell(strcmp(fieldnames(out),'dayIdx'),:));
    dayIdx = repelem(dayIdx,cellfun(@length,outCell(strcmp(fieldnames(out),'cIdx'),:))); 
    state = cell2mat(outCell(strcmp(fieldnames(out),'state'),:)); 
    
    uniday = unique(dayIdx); dn = length(uniday);
    for p = 1:pn,
        pval = cell2mat(outCell(strcmp(fieldnames(out),poi{p}),:)');
        if strcmp(poi{p}(1:3),'spd'),                 pval = pval/14;
        elseif strcmp(poi{p}(1:3),'acc'),             pval = pval/14*1e3;
        elseif strcmp(poi{p},'angSpdCorner'),         pval = rad2deg(pval);
        elseif strcmp(poi{p},'angConsistencyCorner'), pval = rad2deg(pval)*1e3;
        elseif strcmp(poi{p},'durationCorner'),       pval = pval/1e3;
        elseif strcmp(poi{p}(1:3),'joy'),             pval = pval/(1e3*sqrt(2))*100;
        end

        for d = 1:dn,
            for h = 1:2,
                sel = state==h & dayIdx==uniday(d);
                tmp = nanmean(pval(sel));
                val{m,h}(d,p) = tmp;
            end
        end
    end
end



[mu1,ci1] = sem(cell2mat(val(:,1)),'no',17);
[mu2,ci2] = sem(cell2mat(val(:,2)),'no',17);

mudata = [mu1;mu2];

nf; 
lims = [0.3, 0, 0, 63;...
        0.65, 30,  6, 70];

spider_plot_R2019b(mudata,...
    'AxesInterval',1,...
    'AxesLabels','none',...
    'AxesColor', [1,1,1]*0.8,...%'none',...
    'LineStyle','-',...
    'Color', [condCols{1};condCols{2}],...
    'AxesLimits', lims,...
    'AxesShaded', 'on',...
    'AxesShadedLimits',{[mu1-ci1;mu1+ci1];[mu2-ci2;mu2+ci2]},...
    'AxesShadedColor', {condCols{1}',condCols{2}'},...
    'AxesShadedTransparency', 0.2,...
    'Marker', 'o',...
    'AxesDisplay', 'all',...
    'AxesLabels',{sprintf('Speed\n(distance/s)'),sprintf('Headturn\nconsistency(%s/s)',char(176)),sprintf('Duration (s)'),sprintf('Joystick\nintensity(%%)')},...
    'AxesLabelsEdge',[1,1,1]);
legend({'Explore-like','Exploit-like'})




end

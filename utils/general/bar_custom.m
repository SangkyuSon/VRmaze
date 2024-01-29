function bar_custom(data,varargin)
% data need to be in size of (number of data) X (variables)
% options = struct('LineColor',      [0,0,0],            ...
%                  'FaceColor',      [1,1,1],                  ...
%                  'LineStyle',      '-',                ...
%                  'x',              0,               ...
%                  'xName',          [],               ...
%                  'oriVer',         0,                  ...
%                  'ttest',          0,....

% setting options
barNo = size(data,2);
options = struct('LineColor',      [0,0,0],            ...
    'FaceColor',      [1,1,1],                  ...
    'LineStyle',      '-',                ...
    'x',              1:barNo,               ...
    'xName',          [],               ...
    'oriVer',         0,                  ...
    'ttest',          0,....
    'ptest',          0,....
    'scatter',        nan,...
    'std',            0,...
    'data2',          [],...
    'compare',        0,...
    'errorbar',       0);
options = checkOptions(options,varargin{:});
options.barwidth = 1/(1+~isempty(options.data2))*0.8;

% plotting
if options.scatter==1, 
    alp = 0.2;
    plot(options.x,data,'Color',[options.LineColor,alp])
    
end

ci = zeros(barNo,2);
for bn = 1:barNo,
    
    [mu(bn,1),ci(bn,:)] = sem(data(:,bn),'no',length(data(:,bn)),'oriVer',options.oriVer,'std',options.std);
    if options.std==3, ci(bn,1) = -ci(bn,1); end
    if ~options.errorbar, bar(options.x(bn),mu(bn),options.barwidth,'EdgeColor',options.LineColor,'FaceColor',options.FaceColor,'LineStyle',options.LineStyle); hold on; end
    if ~options.errorbar, errorbar(options.x(bn),mu(bn),ci(bn,1),ci(bn,2),'Color',options.LineColor); end
    set(gca,'xtick',options.x);
    if ~isempty(options.xName), set(gca,'xticklabel',options.xName); end
    if ~isnan(options.scatter), 
        %s = scatter(repmat(options.x(bn),length(data(:,bn)),1),data(:,bn),'MarkerFaceColor',options.LineColor,'MarkerEdgeColor',[1,1,1]);        
        %xs = repmat(options.x(bn),length(data(:,bn)),1)+min(diff(options.x))*options.scatter*(rand(length(data(:,bn)),1)*2-1);
        if options.scatter ~= 1,
            xs = repmat(options.x(bn),length(data(:,bn)),1)+1*options.scatter*(rand(length(data(:,bn)),1)*2-1);
            plot(xs,data(:,bn),'o','MarkerFaceColor',options.LineColor,'MarkerEdgeColor',[1,1,1]);
            hold on;
        end
    end
    
    % stats
    if options.ttest,
        try,
            [h,p,~,stat] = ttest(data(:,bn));
            if h, col = [1,0,1]; else col = [0,0,0]; end
            text(options.x(bn),mu(bn)+sign(mu(bn))*ci(bn)/2,sprintf('t:%.4f\np:%.4f',stat.tstat,p),'Color',col,'HorizontalAlignment','center')
        end
    end
    if options.ptest,
        try,
            [p,stat] = sig(data(:,bn),'perm',1);
            if p < 0.05, col = [1,0,1]; else col = [0,0,0]; end
            text(options.x(bn),mu(bn)+sign(mu(bn))*ci(bn)/2,sprintf('t:%.4f\np:%.4f',stat,p),'Color',col,'HorizontalAlignment','center')
        end
    end
    
    if ~isempty(options.data2),    
        [mu2(bn),ci2(bn,:)] = sem(options.data2(:,bn),'no',length(options.data2(:,bn)),'oriVer',options.oriVer,'std',options.std);
        bar(options.x(bn)+0.5,mu2(bn),options.barwidth,'EdgeColor',options.LineColor,'FaceColor',options.FaceColor,'LineStyle',options.LineStyle);
        errorbar(options.x(bn)+0.5,mu2(bn),ci2(bn),'Color',options.LineColor);
        
        if options.ttest,
            try,
                [h,p,~,stat] = ttest(options.data2(:,bn));
                if h, col = [1,0,1]; else col = [0,0,0]; end
                text(options.x(bn)+0.5,mu2(bn)+sign(mu2(bn))*ci2(bn)/2,sprintf('t:%.4f\np:%.4f',stat.tstat,p),'Color',col)
            end
        end
        
        if options.compare,
            comheight(bn) = max(mu(bn)+ci(bn),mu2(bn)+ci2(bn))*1.1;
            line([0,0.5]+options.x(bn),[comheight(bn),comheight(bn)],'Color',[0,0,0]);
            try,[h,p,~,stat] = ttest(data(:,bn)-options.data2(:,bn));
            catch,[h,p,~,stat] = ttest2(data(:,bn),options.data2(:,bn)); end

            if options.ptest,
                p = sig(data(:,bn)-options.data2(:,bn),'perm',1); h = (p<0.05)*1;
            end
            if h, col = [1,0,1]; else col = [0,0,0]; end
            text(options.x(bn),comheight(bn)*1.1,sprintf('t:%.4f\np:%.4f',stat.tstat,p),'Color',col)
        end
    end
    
    
end
if options.errorbar, hold on;errorbar(options.x,mu,ci(:,1),ci(:,2),'Color',options.LineColor,'LineStyle',options.LineStyle); end
%ylim([min([mu-ci,mu2-ci2,0])*1.1,max([mu+ci,mu2+ci2])*1.5])

if ~isempty(options.data2), ylim([min([mu-ci,mu2-ci2])*(1-sign(min([mu-ci,mu2-ci2]))*0.1),max([mu+ci,mu2+ci2])*(1+sign(max([mu+ci,mu2+ci2]))*0.3)]);
else, ylim([min(min([mu-ci]))*(1-sign(min(min([mu-ci])))*0.1),max(max([mu+ci]))*(1+sign(max(max([mu+ci])))*0.3)]); end

if options.errorbar, xlim([min(options.x)-0.5,max(options.x)+0.5]); end


end
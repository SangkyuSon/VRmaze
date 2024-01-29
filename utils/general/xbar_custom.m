function xbar_custom(x,y,varargin)

if size(x,1) == 1, x = x'; end
if size(y,1) == 1, y = y'; end

options = struct(...
    'Color',[0,0,0],...
    'LineWidth',3,...
    'scatter',  1,...
    'scatterColor',[0,0,0],...
    'scatterAlpha',0.5,...
    'std',      0);
options = checkOptions(options,varargin{:});

[xmu,xci] = sem(x,'no',size(x,1),'std',options.std);
[ymu,yci] = sem(y,'no',size(y,1),'std',options.std);

if options.scatter,
    scatter(x,y,50,options.scatterColor,'filled','MarkerFaceAlpha',options.scatterAlpha)
end
line([xmu-xci,xmu+xci],[ymu,ymu],'Color',options.Color,'LineWidth',options.LineWidth);
line([xmu,xmu],[ymu-yci,ymu+yci],'Color',options.Color,'LineWidth',options.LineWidth);


end
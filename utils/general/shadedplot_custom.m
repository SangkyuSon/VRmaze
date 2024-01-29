function shadedplot_custom(data,NoS,varargin)
% shadedplot(data,NoS,varargin)
%   NoS      :: number of subject
%   varargin ::'alpha'     = 0.1 (default)
%              'Color'     = black
%              'LineWidth' = 2
%              'LineStyle' = '-',                ...
%              'xAxis'     = 1:end
%              'std'       = 0
%              'decal'      = 0
%              'nocal'     = 0 % calculate sem by itself?
if nargin < 2, NoS = size(data,1); end
if isempty(NoS),NoS = size(data,1); end

data = squeeze(data);
options = struct('alpha',          0.1,                  ...   
                 'Color',          [0,0,0],            ...
                 'LineWidth',      0.7124,                  ...
                 'LineStyle',      '-',                ...
                 'xAxis',          1:size(data,2),...
                 'std',            0,...
                 'nocal',          0,...
                 'gfilt',          0,...
                 'oriVer',         0);
options = checkOptions(options,varargin{:});
if options.gfilt, data = gfilt2(data,options.gfilt,options.oriVer); end
[mu,ci] = sem(data,'no',NoS,'oriVer',options.oriVer,'std',options.std);

%% area plotting
if options.std ~= 3, y = [mu-ci; ci*2]';
else,                y = [ci(1,:)+mu;ci(1,:).*sign(ci(1,:))+ci(2,:)]';
end

ha = area(options.xAxis, y,...
    'LineStyle','none');
alpha(options.alpha)
set(ha(1), 'FaceColor', 'none') % this makes the bottom area invisible
%set(ha(1), 'FaceColor', [1,1,1])
set(ha(2), 'FaceColor', options.Color) 
%set(ha(2), 'FaceAlpha', options.alpha) 
hold on;
plot(options.xAxis,mu,...
    'Color',options.Color,...
    'LineStyle',options.LineStyle,...
    'LineWidth',options.LineWidth)
xlim([options.xAxis(1),options.xAxis(end)])
%hold on;plot(options.xAxis,zeros(length(options.xAxis),1),'Color',[1,1,1])

maxval = nanmax(nanmax([mu-ci,mu+ci]));
maxval = maxval.*(1+sign(maxval)*0.05);

minval = nanmin(nanmin([mu-ci,mu+ci]));
minval = minval.*(1+sign(minval)*-0.05);

ylim([minval,maxval]);

% put the grid on top of the colored area
set(gca, 'Layer', 'top')

grid off
function out = infmean(data,dim)
if nargin < 2, dim = 1; end

data(data==Inf) = nan;
out = nanmean(data,dim);

end
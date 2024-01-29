function out = infstd(data,dim)
if nargin < 2, dim = 1; end

data(data==Inf) = nan;
out = nanstd(data,dim);

end
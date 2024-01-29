function outIdx = finddim(data,dim)
if nargin < 2, dim = 1;end 
if dim == 2, data = data'; end

for c = 1:size(data,1),
    outIdx{c}  = find(data(c,:));
end

end

function data = transferVal(data,idx,val)

if length(idx)==1, idx = data==idx; end
idx = boolean(idx);

if ~isempty(val),  data(idx) = val;
else,              data(idx) = [];
end

end
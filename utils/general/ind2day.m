function out = ind2day(data,dayIdx)

npt = size(data,2);

uniday = sort(unique(dayIdx));
dn = length(uniday);

out = zeros(dn,npt);
for d = 1:dn,
    
    for n = 1:npt,
        tmp = data(dayIdx==uniday(d),n);
        out(d,n) = nanmean(tmp(~isinf(tmp)),1);
    end
    %out(d,:) = median(data(dayIdx==uniday(d),:),1);
end

end
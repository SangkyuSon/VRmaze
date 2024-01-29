function data = gfilt2(data,sz,oriVer)
% data = gfilt2(data,sz)
% data = (trial) X (time)

if nargin < 3, oriVer = 0; end
n = size(data,1);

for k = 1:n
    if oriVer == 0,
        data(k,:) = gaussianFilter(data(k,:),sz);
    elseif oriVer == 1,
        data(k,:) = gaussianFilterOri(data(k,:)',sz);
    elseif oriVer == 2,
        data(k,:) = gaussianFilterdir(data(k,:)',sz);
    end
end

end

function out = gaussianFilterOri(array, sigma)

if sigma <= 0, out = array; 
else
hn = round(sigma * 3.0);
filterBins = hn * 2 + 1;
w = fspecial('gaussian', [1 filterBins], sigma)';
zeropad = zeros(hn,1);
padded = [zeropad;array;zeropad];
out = zeros(size(array));
for s = 1:length(array)
    out(s) = circ_mean_ori(padded((s):(s+hn*2)),w);
end
end
end


function out = gaussianFilterdir(array, sigma)

if sigma <= 0, out = array; 
else
hn = round(sigma * 3.0);
filterBins = hn * 2 + 1;
w = fspecial('gaussian', [1 filterBins], sigma)';
zeropad = zeros(hn,1);
padded = [zeropad;array;zeropad];
out = zeros(size(array));
for s = 1:length(array)
    out(s) = rad2deg(circ_mean(deg2rad(padded((s):(s+hn*2))),w));
end
end
end
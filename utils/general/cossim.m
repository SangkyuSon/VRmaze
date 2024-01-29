function out = cossim(x,y)

if size(x,2)~=1, x = x'; end
if size(x,1)~=size(y,1), y = y'; end
if size(x,1)~=size(y,1), error('check size of Y values'); end

n = size(y,2);
for k = 1:n, out(k) = dot(x,y(:,k))/(norm(x)*norm(y(:,k))); end

end
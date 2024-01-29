function [last,bgn] = checkPerc(fin,cur,last,int)

if nargin < 4, int = 10; end

if cur==1, tic; end
cperc = floor(((cur/fin)*100)/int);
if last~=cperc,fprintf('%.0f%% (%.1f m)\n',cperc*int,toc/60); last = cperc; end
if cur==fin, fprintf('done.\n'); end

end
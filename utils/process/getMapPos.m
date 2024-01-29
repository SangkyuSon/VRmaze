function [cx,cy,w,x,y,gx,gy,px,py] = getMapPos(st)
if nargin < 1 st = 1; end
x1 = -35:st:21;
y1 = ones(1,length(x1))*-21;

x2 = -21:st:35;
y2 = ones(1,length(x2))*-7;

x3 = -35:st:21;
y3 = ones(1,length(x3))*7;

x4 = -21:st:7;
y4 = ones(1,length(x4))*21;

y5 = -35:st:7;
x5 = ones(1,length(y5))*-21;

y6 = -35:st:21;
x6 = ones(1,length(y6))*-7;

y7 = -21:st:35;
x7 = ones(1,length(y7))*7;

y8 = -35:st:21;
x8 = ones(1,length(y8))*21;

x = [x1,x2,x3,x4,x5,x6,x7,x8];
y = [y1,y2,y3,y4,y5,y6,y7,y8];

cx = [-21,-7,7,21,-21,-7,7,21,-21,-7,7,21,-7,7];
cy = [-21,-21,-21,-21,-7,-7,-7,-7,7,7,7,7,21,21];
w = 2;

gx = [-14,0,-14,7];
gy = [-7,7,21,28];

px = [-28,14,-28];
py = [-21,-7,7];

end
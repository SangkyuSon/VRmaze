function nf

set(0,'DefaultFigureWindowStyle','docked')
ssz = get(0,'ScreenSize');
if strfind(pwd,'/Volumes/'), ssz(3) = ssz(3)*2; end
    
sz = 500;
fn = findobj('type','figure');
if length(fn)==0,
    pos = [ssz(3)-sz,ssz(4)-sz-100,sz,sz];
else
    for f = 1:length(fn),
        xx(f) = fn(f).Position(1);
    end
    pos = [min(xx)-sz,ssz(4)-sz-100,sz,sz];
    pos = max(pos,0);
end

figure('Position',pos)
%movegui('northeast');

end
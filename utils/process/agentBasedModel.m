function out = agentBasedModel(dataDir) 

fileName = sprintf('abm.mat');
[isread,out] = dealFile(dataDir,fileName); 
if ~isread

    pn1 = 26;
    pn2 = 21;
    
    istrat = linspace(-0.6,0.4,pn1);
    ostrat = linspace(-0.4,0.4,pn2);

    [I,O] = meshgrid(istrat,ostrat);

    dn = 50;
    tn = 30;
    rew = zeros(dn,tn,numel(I));
    parfor i = 1:numel(I),
        coef = [I(i);O(i)];
        out = abm(coef,dn,tn);
        rew(:,:,i) = out;
    end

    for d = 1:dn, for t = 1:tn,rrew(:,:,d,t) = reshape(squeeze(rew(d,t,:)),1,pn2,pn1); end; end

    data.rew = rrew;
    data.x = istrat;
    data.y = ostrat;


    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end

function crit = initCrit
crit = ones(14,4);
crit(1,[3,4]) = nan;
crit(2,[4]) = nan;
crit(3,[4]) = nan;
crit(4,[1,4]) = nan;
crit(5,[3]) = nan;
crit(8,[1]) = nan;
crit(9,[2,3]) = nan;
crit(12,[1,2]) = nan;
crit(13,[2,3]) = nan;
crit(14,[1,2]) = nan;
end

function actrew = abm(coef,dn,tn)

for d = 1:dn,

    [map,visitMap,jackpot,subgoal,corners] = initializeDay;
    cnt = 0;

    for k = 1:tn,
        if cnt == 0, oopt = []; oinfo = []; opt = nan; info = nan; traj = [];end
       [visitMap,actreward{k},cnt,tcnt{k},traj,info,opt,oopt,oinfo] = doTrial(map,visitMap,oopt,oinfo,opt,info,traj,cnt,jackpot,subgoal,corners,coef);
    end
    actrew(d,:) = cellfun(@(x1,x2) sum(x1)/(x2-2),actreward,tcnt);
end


end

function [map,visitMap,jackpot,subgoal,corners] = initializeDay

map = initMap;
jackpot = find(map==2);
jackpot = jackpot(randperm(length(jackpot),1));
jackpot = [mod(jackpot,9),ceil(jackpot/9)];

jackpot(jackpot(:,1)==0,1) = 9;
jackpot(jackpot(:,1)==0,2) = jackpot(jackpot(:,1)==0,2)-1;

map(jackpot(1),jackpot(2)) = 4;

subgoal = find(map==3);
subgoal = [mod(subgoal,9),ceil(subgoal/9)];

corners = find(map==2 | map==4);
corners = [mod(corners,9),ceil(corners/9)];

visitMap = zeros(size(map));


% 1 : normal path
% 2 : corner
% 3 : subgoal
% 4 : jackpot

end

function [visitMap,actreward,cnt,tcnt,traj,info,opt,oopt,oinfo] = doTrial(...
    map,visitMap,oopt,oinfo,opt,info,traj,cnt,...
    jackpot,subgoal,corners,...
    coef)

kmap = map;
moveUnit = 2;
posmov = [1,0;0,1;-1,0;0,-1];
maxIter = 1e2;
minDist = 5;

done = 0;tcnt = 0;
crit = initCrit;

while ~done,
    tcnt = tcnt + 1;
    cnt = cnt + 1;
    if tcnt == 1,
        tmp = find(sum(abs(corners-jackpot),2) > minDist);
        cpos = corners(tmp(randperm(length(tmp),1)),:);
        visitMap(cpos(1),cpos(2)) = visitMap(cpos(1),cpos(2))+1;
    else, cpos = npos; end
    
    traj(cnt,:) = cpos;
    ppos = cpos+posmov*moveUnit;

    [oinfo(cnt,:),oopt(cnt,:),ovisit] = getIdx(cpos,ppos,jackpot,subgoal,moveUnit,kmap,visitMap);
    
    %if cnt > 300, keyboard; end
    crit = undateCrit(crit,traj,cpos,oinfo,info,opt,coef,moveUnit,cnt,corners);
        
    [npos,opt(cnt),info(cnt)] = makeChoice(crit(sum(corners==cpos,2)==2,:).*max(ovisit,0.1),ppos,oopt,oinfo);

    [visitMap,actreward] = updateMaps(visitMap,cpos,npos,jackpot,subgoal);
    

    if sum(jackpot==npos)==2 || tcnt >= maxIter
        done = 1;
    end
    
end

end

function crit = undateCrit(crit,traj,cpos,oinfo,info,opt,coef,moveUnit,cnt,corners)

try
    
    prevVisit = find(sum(traj(1:cnt-1,:)==cpos,2)==2,1,'last');
    isinfo = max(oinfo(prevVisit,:))==info(prevVisit);
    isopt = opt(prevVisit) > 0.5;

    if coef(1) <= 0, ratio(1) = (isinfo==0)*coef(1);      % avoidance
    else,            ratio(1) = (isinfo==1)*coef(1); end  % reinforcement

    if coef(2) <= 0, ratio(2) = (isopt==0)*coef(2);
    else,            ratio(2) = (isopt==1)*coef(2); end

    if     sum(traj(prevVisit,:)-traj(prevVisit+1,:)==[+moveUnit,0])==2, prevChoice = 1;
    elseif sum(traj(prevVisit,:)-traj(prevVisit+1,:)==[0,+moveUnit])==2, prevChoice = 2;
    elseif sum(traj(prevVisit,:)-traj(prevVisit+1,:)==[-moveUnit,0])==2, prevChoice = 3;
    elseif sum(traj(prevVisit,:)-traj(prevVisit+1,:)==[0,-moveUnit])==2, prevChoice = 4;
    else prevChoice = []; end

    cIdx = sum(corners==cpos,2)==2;
    chgCrit = sum(ratio*crit(cIdx,prevChoice));
    %chgCrit = sum(ratio);
    crit(cIdx,prevChoice) = max(crit(cIdx,prevChoice) + chgCrit,0);
    
end

end

function [visitMap,actreward] = updateMaps(visitMap,cpos,npos,jackpot,subgoal)

coriPos = (cpos+npos)/2;

visitMap(npos(1),npos(2)) = visitMap(npos(1),npos(2)) + 1;
visitMap(coriPos(1),coriPos(2)) = visitMap(coriPos(1),coriPos(2)) + 1;

if sum(jackpot==npos)==2,       actreward = 1;
elseif sum(subgoal==npos,2)==2, actreward = 0.125;
else                            actreward = 0;
end

end

function [npos,opt,info] = makeChoice(crit,ppos,oopt,oinfo)

choice = pdfChoice(crit.*~isnan(oopt(end,:))+1e-10);

%tmp = find(crit==max(crit));
%choice = tmp(randperm(length(tmp),1));

npos = ppos(choice,:);

opt = oopt(end,choice);
info = oinfo(end,choice);

end

function choice = pdfChoice(given)

tmp = given./nansum(given);
%tmp(isnan(given)) = nan;
%tmp = nan(4,1);
%tmp(~isnan(given)) = softmax(given(~isnan(given))*40);

choice = rand;
choice = find(choice < nancumsum(tmp));
try,choice = choice(1);end
if isempty(choice),
    choice = find(~isnan(tmp));
    choice = choice(randperm(length(choice),1));
end

end

function [oinfo,oopt,ovisit] = getIdx(cpos,ppos,jackpot,subgoal,moveUnit,kmap,visitMap)

% compute info
maxInfo = 30;
ovisit = nan(4,1);
nanPath = ones(1,4);
for o = 1:4,
    try,
        if kmap(ppos(o,1),ppos(o,2)) ~= 0,
            ovisit(o) = visitMap(ppos(o,1),ppos(o,2));
            nanPath(o) = 0;
        end
    end
end
oinfo = ovisit./nansum(ovisit);
oinfo = log2(1./oinfo);
oinfo = min(oinfo,maxInfo);

% compute reward
jackpotDist = sum(abs(cpos-jackpot),2);
jackpotChg = sum(abs(ppos-jackpot),2) - jackpotDist;

[subgoalDist,cSubgoalIdx] = min(sum(abs(cpos-subgoal),2));
csubgoal = subgoal(cSubgoalIdx,:);
subgoalChg = sum(abs(ppos-csubgoal),2) - subgoalDist;

ratio = [8,1]./[jackpotDist,subgoalDist];
ratio = ratio./sum(ratio);
oopt = 1 - (sum([jackpotChg,subgoalChg]/moveUnit.*ratio,2)+1)/2;

nanPath = boolean(nanPath);

oopt(nanPath) = nan;
oinfo(nanPath) = nan;
ovisit = ovisit'~=0;

end

function map = initMap


[cx,cy,~,x,y,gx,gy,px,py] = getMapPos;

xx = round((x+33)/7);
yy = round((y+33)/7);

sel = yy>0 & xx>0;
xx = xx(sel);
yy = yy(sel);

map = zeros(9);
for i1 = 1:length(xx)
    map(xx(i1),yy(i1)) = 1;
end
map = map(1:9,1:9);

map([11,13,15,17,29,31,33,35,47,49,51,53,67,69]) = 2;

sx = round(([gx,px]+33)/7);
sy = round(([gy,py]+33)/7);
for i1 = 1:length(sx),
    map(sx(i1),sy(i1)) = 3;
end

map(2,8) = 0;
map(8,8) = 0;

end

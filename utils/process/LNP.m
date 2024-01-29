function out = LNP(dataDir,subName,ROI)

fileName = sprintf('%s_%s_LNP.mat',subName,ROI);

[isread,out] = dealFile(dataDir,fileName);
if ~isread,

    cn = length(getAllFiles(fullfile(outDir,'LNP_prep'),sprintf('%s_%s*.mat',subName,ROI),1));
    opts = optimset('Gradobj','on','Hessian','on','Display','off','TolFun',1e-8,'MaxIter',1e3);

    parno = [9,9,4,7];
    permNo = 100;
    
    last = 0;
    rsqs = zeros(cn,length(parno)); rsqs_pm = zeros(cn,length(parno),permNo);
    for c = 1:20,
        
        celldata = LNP_dataprep(dataDir,subName,ROI,c);

        X = prepX(celldata,parno);
        y = celldata.psth;

        [param,yHat] = fitLNP(X,y,opts);
        [tuningTrue,tuningHat] = tuningLNP(X,y,param,parno);
        rsqs(c,:) = calTuningRSQ(tuningTrue,tuningHat,parno);

        for pm = 1:permNo,
            pmX = X(:,randperm(length(X)));
            [param,yHat] = fitLNP(pmX,y,opts);
            [tuningTrue,tuningHat] = tuningLNP(X,y,param,parno);
            rsqs_pm(c,:,pm) = calTuningRSQ(tuningTrue,tuningHat,parno);
        end
        
        last = checkPerc(400,c,last);
    end

    data.rsq = rsqs;
    data.rsq_pm = rsqs_pm;

    [~,out] = dealFile(dataDir,fileName,'data',data);
end

end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [tuningTrue,tuningHat] = tuningLNP(X,y,param,parno)

tStepSz = 100;

pn = length(parno);
for p = 1:pn,
    poi = (1:parno(p))+sum(parno(1:p-1));
    scaleFactor(p) = exp(mean(X(poi,:),2)'*param(poi));
end

for p = 1:pn,
    poi = (1:parno(p))+sum(parno(1:p-1));
    tuningHat(1,poi) = (exp(param(poi)).*prod(scaleFactor(setdiff(1:pn,p))))/(tStepSz/1e3);
    tuningTrue(1,poi) = sum(X(poi,:).*y,2)./sum(X(poi,:),2)/(tStepSz/1e3);
end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function rsq = calTuningRSQ(tuningTrue,tuningHat,parno)

for p = 1:length(parno),
    poi = (1:parno(p))+sum(parno(1:p-1));
    rsq(1,p) = calRSQ(tuningTrue(poi),tuningHat(poi));
end
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [rsq] = calRSQ(trueVal,hatVal)

SSE = sum((trueVal-hatVal).^2);
SST = sum((trueVal-mean(trueVal)).^2);
rsq = 1-(SSE/SST);

end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [param,yHat] = fitLNP(X,y,opts)
init = 1e-3*randn(size(X,1), 1);
param = fminunc(@(param) doLNP(param,X',y'),init,opts);
yHat = exp(X'*param)';
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [f, df, hessian] = doLNP(param,X,y)

lamda = 1e-2;

% compute the firing rate
u = X * param;
rate = exp(u);

% start computing the Hessian
rX = bsxfun(@times,rate,X);
hessian_glm = rX'*X;

% regularize term
regVal = (lamda/2) * sum(exp(param).^2);

% compute f, the gradient, and the hessian
f = sum(rate - y.*u) + regVal;
df = real(X' * (rate - y));
hessian = hessian_glm;
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function [X,parno] = prepX(data,parno)

pos = data.pos;
pos(abs(pos) > 31.4) = sign(pos(abs(pos) > 31.4))*31.4;
pos = floor((data.pos+31.5)/7)+1;

Xx = (pos(1,:)==(1:parno(1))')*1;
Xy = (pos(2,:)==(1:parno(2))')*1;

hd = atan2d(diff(data.pos(2,:)),diff(data.pos(1,:)));
hd = mod(ceil((hd+45+180)/90),4)+1;
Xhd = [zeros(parno(3),1),(hd==(1:parno(3))')*1];

spd = sqrt(sum(diff(data.pos,[],2).^2,1));
spd(spd > 1.5) = 0;
spd = floor((spd/1.5)*parno(4))+1;

Xspd = [zeros(parno(4),1),(spd==(1:parno(4))')*1];

X = cat(1,Xx,Xy,Xhd,Xspd);

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
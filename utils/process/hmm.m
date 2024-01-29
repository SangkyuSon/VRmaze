function out = hmm(dataDir,subName)
% this functions requires hidden Markov model toolbox
% from https://www.cs.ubc.ca/~murphyk/Software/HMM/hmm.html

fileName = sprintf('%s_hmm.mat',subName);
[isread,out] = dealFile(dataDir,fileName);
if ~isread,
    %%

    idx = extractLowLevelFeatures(dataDir,subName);
    [data,dayIdx,idx] = getData(idx);
    
    nHidden = 2;
    iterNo = 100;
    kout = hmm_sum(data,nHidden,iterNo);

    for k = 1:size(data,2),
        kdata = data{k};
        prob = mixgauss_prob(kdata, kout.mu, kout.sig, kout.mix);
        state = viterbi_path(kout.prior, kout.transmat, prob);
        idx(k).state = state;
    end
    data = idx;
        
    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end


function [data,dayIdx,idx] = getData(idx)


n = size(idx,2);

clear data
for k = 1:n,
    data{k} = [...
        [],...
        idx(k).angSpdCorner,...
        [],...
        idx(k).angConsistencyCorner,...
        [],...
        idx(k).durationCorner,...
        [],...
        idx(k).spdCorner,...
        idx(k).spdAfter,...
        idx(k).spdBefore,...
        [],...
        idx(k).joyCorner,...
        idx(k).joyAfter,...
        idx(k).joyBefore,...
        [],...
        idx(k).accCorner,...
        idx(k).accAfter,...
        idx(k).accBefore,...
        []]';

    checkNan = 1:size(data{k},1);
    for c = checkNan, data{k}(c,isnan(data{k}(c,:))) = 0;end
    dayIdx(k) = idx(k).dayIdx;
end

seldayIdx = find(sum(dayIdx==find(sum(dayIdx==(1:max(dayIdx))',2)>20)));
data(setdiff(1:n,seldayIdx)) = [];
dayIdx = dayIdx(seldayIdx);
n = length(seldayIdx);

idx = idx(seldayIdx);

end


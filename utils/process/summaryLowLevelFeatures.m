function out = summaryLowLevelFeatures(dataDir,subName)
 % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
fileName = sprintf('%s_summaryLowLevelFeatures.mat',subName);
[isread,out] = dealFile(dataDir,fileName);
if ~isread

    % load data
    [idxCell,idxName,state,dayIdx] = loadData(dataDir,subName);
    
    % get idx
    uniday = unique(dayIdx); dn = length(uniday);
    for d = 1:dn,
        dIdx = dayIdx==uniday(d);
        cIdx = cell2mat(idxCell(strcmp(idxName,'cIdx'),dIdx)');
        opt = cell2mat(idxCell(strcmp(idxName,'error'),dIdx)'); opt = 1-opt(:,4);
        info = cell2mat(idxCell(strcmp(idxName,'probBeenThereSelNorm'),dIdx)'); info = log2(1./info);
        
        data.cIdx{d} = cIdx;
        data.state{d} = cell2mat(state(dIdx));
        data.opt{d} = opt;
        data.info{d} = info;
        data.oopt{d} = cell2mat(idxCell(strcmp(idxName,'oopt'),dIdx)');
        data.oinfo{d} = cell2mat(idxCell(strcmp(idxName,'oinfo'),dIdx)');
    end

    data = getRank(data);

    [isread,out] = dealFile(dataDir,fileName,'data',data);
end

end

function data = getRank(data)
%data.info = cellfun(@(x1) transferVal(x1,x1==Inf,30),data.info,'un',0);
%data.oinfo = cellfun(@(x1) transferVal(x1,x1==Inf,30),data.oinfo,'un',0);

cIdx = data.cIdx;
cIdx = cellfun(@(x1) transferVal(x1,x1==14,15),cIdx,'un',0);
cIdx = cellfun(@(x1) transferVal(x1,x1==13,14),cIdx,'un',0);

choice = cellfun(@(x1) x1(1:end-1)-x1(2:end),cIdx,'un',0);
choice = cellfun(@(x1) transferVal(x1,x1==-1,11),choice,'un',0);
choice = cellfun(@(x1) transferVal(x1,x1==-3,12),choice,'un',0);
choice = cellfun(@(x1) transferVal(x1,x1==+1,13),choice,'un',0);
choice = cellfun(@(x1) transferVal(x1,x1==+4,14),choice,'un',0);
choice = cellfun(@(x1) transferVal(x1,x1<10,nan),choice,'un',0);
choice = cellfun(@(x1) [x1-10;nan],choice,'un',0);
yesChoice = cellfun(@(x1) ~isnan(x1),choice,'un',0);

clear crank orank
for d = 1:size(choice,2)
    for c = 1:size(choice{d},1)
        tmp = data.oinfo{d}(c,:);
        nanIdx = isnan(tmp);
        tmp = tmp(~nanIdx);
        [val,ranktmp] = sort(tmp,'descend');

        ranks = nan(1,4);
        ranks(~nanIdx) = ranktmp;

        try,   crank{d}(c,1) = ranks(choice{d}(c));
        catch, crank{d}(c,1) = nan; end

        tmp = data.oopt{d}(c,:);
        nanIdx = isnan(tmp);
        tmp = tmp(~nanIdx);
        [val,ranktmp] = sort(tmp,'descend');

        ranks = nan(1,4);
        ranks(~nanIdx) = ranktmp;

        try,   orank{d}(c,1) = ranks(choice{d}(c));
        catch, orank{d}(c,1) = nan; end
    end
end
data.irank = crank;
data.orank = orank;
data.yesChoice = yesChoice;
end

function [idxCell,idxName,state,dayIdx] = loadData(dataDir,subName)

hmmout = hmm(dataDir,subName);
hmmCell = struct2cell(hmmout);
state = cellfun(@(x1) stateSeq(x1),hmmCell(strcmp(fieldnames(hmmout),'state'),:),'un',0);


idx = getidx7(dataDir,subName);
idxCell = squeeze(struct2cell(idx));
dayIdx = cell2mat(idxCell(strcmp(fieldnames(idx),'dayIdx'),:));

sel = boolean(sum(dayIdx==find(sum(dayIdx==unique(dayIdx)',2)>20),1));
idx = idx(sel);
idxCell = idxCell(:,sel);
dayIdx = dayIdx(sel);
idxName = fieldnames(idx);

end

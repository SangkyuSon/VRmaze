function out = extractLowLevelFeatures(dataDir,subName)

load(fullfile(dataDir,sprintf('%s_LowLevelFeatures',subName)))
out = data;

end

% data = rmfield(data,'probBeenThereSel');
% data = rmfield(data,'probBeenThereAns');
% data = rmfield(data,'probBeenThereAnsNorm');
% data = rmfield(data,'probAll');
% data = rmfield(data,'numOfExplore');
% data = rmfield(data,'angSpdAfter');
% data = rmfield(data,'angSpdBefore');
% data = rmfield(data,'durationPerExplore');
% data = rmfield(data,'revisitNum');
% data = rmfield(data,'revisitAfterCorners');
% data = rmfield(data,'revisitDuration');
% data = rmfield(data,'oemp');
% data = rmfield(data,'emp');
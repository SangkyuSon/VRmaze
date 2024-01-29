function [isread,data] = dealFile(saveDir,fileName,varargin)
% [isdata,data] = dealFile(saveDir,fileName,varargin)
% options = struct('data',  [],...
%                  'resave',0,...
%                  'recal', 0);
try, if ~exist(saveDir), mkdir(saveDir); end; end
options = struct('dir',   saveDir,...
    'name',  fileName,...
    'data',  []);
options = checkOptions(options,varargin{:});
data = options.data;

isread = exist(fullfile(options.dir,options.name),'file')==2 & isempty(data);

if isread, load(fullfile(options.dir,options.name),'data'); 
elseif ~isempty(data), save(fullfile(options.dir,options.name),'data'); end

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% function [isread,data] = dealFile(saveDir,fileName,varargin)
% % [isdata,data] = dealFile(saveDir,fileName,varargin)
% % options = struct('data',  [],...
% %                  'resave',0,...
% %                  'recal', 0);
% try if ~exist(saveDir), mkdir(saveDir); end; end
% options = struct('dir',   saveDir,...
%     'name',  fileName,...
%     'data',  [],...
%     'resave',0,...
%     'recal', 0);
% options = checkOptions(options,varargin{:});
% data = options.data;
% 
% %isdata = ~isempty(data);
% %istime = 1;
% [istime,isdata] = checkContinue(data,options);
% 
% if ~isdata && istime % reading
%     load(fullfile(options.dir,options.name),'data');
% elseif isdata && istime % saving
%     try if ~exist(saveDir), mkdir(saveDir); end; end
%     dataInfo = whos('data');
%     %checkMemory(data);
%     if dataInfo.bytes/(1024)^3 < 2
%         save(fullfile(options.dir,options.name),'data');
%     else
%         save(fullfile(options.dir,options.name),'data','-v7.3');
%     end
% end
% 
% isread = ~isdata && istime;
% 
% end
% 
% function [istime,isdata] = checkContinue(data,options)
% 
% isdata = ~isempty(data);
% 
% if isdata,
%     fileInfo = whos('data');
% else
%     fileInfo = dir(fullfile(options.dir,options.name));
% end
% 
% istime = 1;
% if isempty(fileInfo),
%     istime = 0;
% else
%     bps_data = bps(options.recal);
%     %try avgTime = calAvgTime;catch avgTime = calAvgTime(3);end
%     avgTime = 0;
%     est_minutes = round(fileInfo.bytes*bps_data(isdata+1)*avgTime/60*10)/10;
%     if est_minutes > 10,
%         warning('dealing with data might takes %.1f minutes',est_minutes);
%         istime = input('continue? yes(1) / no(0)  ');
%     end
% end
% 
% end
% function out = bps(recal)
% 
% bpsName = fullfile('Q:','HDD2','projects','_FUNC','bps.txt');
% 
% if ~exist(bpsName) || recal
%     fakeData = rand(11181); % 1gb
%     fakeDataInfo = whos('fakeData');
%     fakeDir = fullfile('Q:','HDD2','projects','temp');
%     mkdir(fakeDir)
%     for lp = 1:5
%         tic;
%         save(fullfile(fakeDir,sprintf('fake_%d.mat',lp)),'fakeData');
%         est(lp,1) = toc;
%     end
%     for lp = 1:5
%         tic;
%         load(fullfile(fakeDir,sprintf('fake_%d.mat',lp)));
%         est(lp,2) = toc;
%     end
%     for lp = 1:5
%         delete(fullfile(fakeDir,sprintf('fake_%d.mat',lp)));
%     end
%     rmdir(fakeDir);
%     out(1:2,1) = mean(est,1)/(fakeDataInfo.bytes*calAvgTime(10));
%     
%     fid = fopen(bpsName,'w');
%     fprintf(fid,'%d %d',out(1),out(2))
%     fclose(fid)
% else
%     fid = fopen(bpsName,'r');
%     out = fscanf(fid,'%f');
%     fclose(fid);
% end
% 
% end
% 
% function avgTime = calAvgTime(tryNo)
% if nargin < 1, tryNo = 1; end
% [~,msg] = dos(sprintf('ping -n %d www.google.com',tryNo));
% msIdx = strfind(msg,'ms');
% eqIdx = strfind(msg,'=');
% avgTime = str2double(msg((eqIdx(end)+1):(msIdx(end)-1)))/32;
% end
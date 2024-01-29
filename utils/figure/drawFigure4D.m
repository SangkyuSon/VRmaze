function drawFigure4D(dataDir,subj)


v1 = interAreal(dataDir,subj{1});
v2 = interAreal(dataDir,subj{2});

o2r = cossim([v1.o2r{1};v2.o2r{1}],[v1.o2r{2};v2.o2r{2}]);
r2o = cossim([v1.r2o{1};v2.r2o{1}],[v1.r2o{2};v2.r2o{2}]);

o2r_bt = cellfun(@(x1,x2,x3,x4) cossim([x1;x2],[x3;x4]),v1.o2r_sf(1,:),v2.o2r_sf(1,:),v1.o2r_sf(2,:),v2.o2r_sf(2,:));
r2o_bt = cellfun(@(x1,x2,x3,x4) cossim([x1;x2],[x3;x4]),v1.r2o_sf(1,:),v2.r2o_sf(1,:),v1.r2o_sf(2,:),v2.r2o_sf(2,:));

nf;
subplot(2,1,1)

data_bt = r2o_bt;
data = r2o;
data = (data - mean(data_bt))/std(data_bt);
data_bt = (data_bt - mean(data_bt))./std(data_bt);

histogram(data_bt,'FaceColor',[1,1,1]*0.8,'EdgeAlpha',0,'Normalization','probability')
line([1,1]*data,[0,0.05],'Color',[0,0,0])
title(sprintf('RSC%sOFC',char(8594)))

subplot(2,1,2)
data_bt = o2r_bt;
data = o2r;
data = (data - mean(data_bt))/std(data_bt);
data_bt = (data_bt - mean(data_bt))./std(data_bt);

histogram(data_bt,'FaceColor',[1,1,1]*0.8,'EdgeAlpha',0,'Normalization','probability')
line([1,1]*data,[0,0.05],'Color',[0,0,0])
title(sprintf('OFC%sRSC',char(8594)))


end

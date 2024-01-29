function out = interAreal(dataDir,subName)

fileName = sprintf('%s_interAreal.mat',subName);
[isread,out] = dealFile(dataDir,fileName);

if ~isread,
    RSC = goalReactivation(dataDir,subName,'RSC');
    OFC = goalReactivation(dataDir,subName,'OFC');

    fr_RSC = frsummary_react(dataDir,subName,'RSC');
    fr_OFC = frsummary_react(dataDir,subName,'OFC');

    fr_RSC = cellfun(@(x1) (x1-mean(x1,1))./std(x1,[],1),fr_RSC.fr.corner,'un',0);
    fr_OFC = cellfun(@(x1) (x1-mean(x1,1))./std(x1,[],1),fr_OFC.fr.corner,'un',0);

    state = RSC.idx.state;

    clear o2r r2o
    for h = 1:2,
        o2r{h} = cell2mat(cellfun(@(x1) x1(2:end),cellfun(@(x,y,idx) glmfit(x(idx==h,:),y(idx==h),'Normal','Constant','on'),fr_OFC,RSC.co,state,'un',0),'un',0)');
        r2o{h} = cell2mat(cellfun(@(x1) x1(2:end),cellfun(@(x,y,idx) glmfit(x(idx==h,:),y(idx==h),'Normal','Constant','on'),fr_RSC,OFC.co,state,'un',0),'un',0)');
    end
    
    bootNo = 3000;
    permNo = 10000;

    cnt = 0; last = 0;
    for bt = 1:bootNo,
        for h = 1:2,
            hIdx = cellfun(@(x1) find(x1==h),state,'un',0);
            btIdx = cellfun(@(x1) x1(ceil(rand(length(x1),1)*length(x1))),hIdx,'un',0);
            
            tmp_o2r = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx),'Normal','Constant','on'),fr_OFC,RSC.co,btIdx,'un',0);
            o2r_bt_vec{h,bt} = cell2mat(cellfun(@(x1) x1(2:end),tmp_o2r,'un',0)');
            
            tmp_r2o = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx),'Normal','Constant','on'),fr_RSC,OFC.co,btIdx,'un',0);
            r2o_bt_vec{h,bt} = cell2mat(cellfun(@(x1) x1(2:end),tmp_r2o,'un',0)');

            cnt = cnt + 1;
            last = checkPerc((bootNo+permNo*2)*2,cnt,last);
        end
    end
    
    for pm = 1:permNo,
        for h = 1:2,
            hIdx = cellfun(@(x1) randperm(length(x1),sum(x1==h)),state,'un',0);

            tmp_o2r = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx(randperm(length(idx)))),'Normal','Constant','on'),fr_OFC,RSC.co,hIdx,'un',0);
            o2r_pm_vec{h,pm} = cell2mat(cellfun(@(x1) x1(2:end),tmp_o2r,'un',0)');

            tmp_r2o = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx(randperm(length(idx)))),'Normal','Constant','on'),fr_RSC,OFC.co,hIdx,'un',0);
            r2o_pm_vec{h,pm} = cell2mat(cellfun(@(x1) x1(2:end),tmp_r2o,'un',0)');

            cnt = cnt + 1;
            last = checkPerc((bootNo+permNo*2)*2,cnt,last);
        end
    end


    for pm = 1:permNo,
        for h = 1:2,
            hIdx = cellfun(@(x1) randperm(length(x1),sum(x1==h)),state,'un',0);

            tmp_o2r = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx),'Normal','Constant','on'),fr_OFC,RSC.co,hIdx,'un',0); 
            o2r_sf_vec{h,pm} = cell2mat(cellfun(@(x1) x1(2:end),tmp_o2r,'un',0)');

            tmp_r2o = cellfun(@(x,y,idx) glmfit(x(idx,:),y(idx),'Normal','Constant','on'),fr_RSC,OFC.co,hIdx,'un',0); 
            r2o_sf_vec{h,pm} = cell2mat(cellfun(@(x1) x1(2:end),tmp_r2o,'un',0)');

            cnt = cnt + 1;
            last = checkPerc((bootNo+permNo*2)*2,cnt,last);
        end
    end
    
    
    data.o2r = o2r;
    data.o2r_bt = o2r_bt_vec;
    data.o2r_pm = o2r_pm_vec;
    data.o2r_sf = o2r_sf_vec;
    
    data.r2o = r2o;
    data.r2o_bt = r2o_bt_vec;
    data.r2o_pm = r2o_pm_vec;
    data.r2o_sf = r2o_sf_vec;
    
    [isread,out] = dealFile(dataDir,fileName,'data',data);

end

end
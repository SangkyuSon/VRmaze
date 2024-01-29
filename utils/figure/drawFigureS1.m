function drawFigureS1(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};

nf;
clear data state
for m = 1:2,
    [mdata,dayIdx] = getPhysicalData(dataDir,subj{m});
    hmmout = hmm(dataDir,subj{m});
    hmmcell = struct2cell(hmmout);
    mstate = cell2mat(hmmcell(strcmp(fieldnames(hmmout),'state'),:));

    mstate = mstate(~sum(isnan(mdata),2));
    mdata = mdata(~sum(isnan(mdata),2),:);
    D = dist(mdata');

    opt.verbose = 1;
    opt.display = 0;
    opt.dims = 2;

    Y = Isomap(D,'k',10,opt);
    Y = Y.coords{1}';

    subplot(1,2,m)
    for h = 1:2,
        hsel = mstate==h;
        scatter(Y(hsel,1),Y(hsel,2),[],condCols{h},'filled','o','MarkerFaceAlpha',0.1)
        hold on;
    end
    xlabel('iso Dim. 1 (a.u.)')
    ylabel('Dim. 2 (a.u.)')
    legend({'Explore-like','Exploit-like'})
    axis square

end


end

function drawFigure1E(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};

clear data state
for m = 1:2,
    [data{m},dayIdx] = getPhysicalData(dataDir,subj{m});
    hmmout = hmm(dataDir,subj{m});
    hmmcell = struct2cell(hmmout);
    state{m} = cell2mat(hmmcell(strcmp(fieldnames(hmmout),'state'),:));
end

mdata = cell2mat(data');
mstate = cell2mat(state);
mstate = mstate(~sum(isnan(mdata),2));
mdata = mdata(~sum(isnan(mdata),2),:);
Y = tsne(mdata);

nf;
for h = 1:2,
    hsel = mstate==h;
    scatter(Y(hsel,1),Y(hsel,2),[],condCols{h},'filled','o','MarkerFaceAlpha',0.1)
    hold on;
end
xlabel('tSNE Dim. 1 (a.u.)')
ylabel('Dim. 2 (a.u.)')
legend({'Explore-like','Exploit-like'})

end

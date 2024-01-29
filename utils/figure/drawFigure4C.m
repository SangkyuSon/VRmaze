function drawFigure4C(dataDir,subj)

condCols = {[228,26,28]./255,[55,126,184]./255};
condName = {'Explore-like','Exploit-like'};

for m = 1:2,
    vecs = interAreal(dataDir,subj{m});

    for h = 1:2,

        o2r_mu(h,m) = mean(cellfun(@(x1) cossim(x1,vecs.o2r{h}),vecs.o2r_bt(h,:)));
        r2o_mu(h,m) = mean(cellfun(@(x1) cossim(x1,vecs.r2o{h}),vecs.r2o_bt(h,:)));

        o2r_perm{h,m} = cellfun(@(x1) cossim(x1,vecs.o2r{h}),vecs.o2r_pm(h,:));
        r2o_perm{h,m} = cellfun(@(x1) cossim(x1,vecs.r2o{h}),vecs.r2o_pm(h,:));
    end
end

nf
for h = 1:2,
    subplot(2,2,h)
    histogram(r2o_perm{h,m},'FaceColor',[1,1,1]*0.8,'EdgeAlpha',0,'Normalization','probability')
    line([1,1]*r2o_mu(h,m),[0,0.05],'Color',condCols{h})
    title(sprintf('RSC%sOFC\n%s',char(8594),condName{h}))


    subplot(2,2,h+2)
    histogram(o2r_perm{h,m},'FaceColor',[1,1,1]*0.8,'EdgeAlpha',0,'Normalization','probability')
    line([1,1]*o2r_mu(h,m),[0,0.05],'Color',condCols{h})
    title(sprintf('OFC%sRSC\n%s',char(8594),condName{h}))
end

end

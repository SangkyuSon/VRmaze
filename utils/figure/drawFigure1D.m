function drawFigure1D(dataDir,subj)


data = [];
for m = 1:2,
    kout = kmean(dataDir,subj{m});
    kout.elbow(:,1,2) = 0;
    mdata = -diff(kout.elbow,[],3);
    data = [data;mdata];
end

nf;
bar_custom(data,'errorbar',1)
xlabel('Number of cluster')
ylabel(sprintf('Cluster distance\n(within-across; a.u.)'))

end

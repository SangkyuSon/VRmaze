function drawFigure3D(dataDir,subj,rois)

nf
abm = agentBasedModel(dataDir);

mdata = mean(mean(abm.rew(:,:,:,20:30),3),4);
mdata = imgaussfilt(mdata,1.5);

heatmap(mdata,abm.x*100,abm.y*100);
colormap('gray')
caxis([0.11,0.15])
title('Change in path''s weight (%)')
xlabel(sprintf('Devalue or reinforce\nnot-informative or informative'))
ylabel(sprintf('Devalue or reinforce\nnot-optimal or optimal'))

end



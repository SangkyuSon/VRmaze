function drawFigure2B(dataDir,subj,rois)

nf;
for r = 1:2,
    jra = [];
    for m = 1:2,
        co = goalReactivation(dataDir,subj{m},rois{r});
        
        clear jr
        for h = 1:3,
            if h == 1,
                jr(:,h) = cellfun(@(x1,x2,x3) nanmean(x1(x2==1 & x3<0.5)),co.co,co.idx.state,co.idx.error,'un',1);
            elseif h == 2,
                jr(:,h) = cellfun(@(x1,x2,x3) nanmean(x1(x2==2 & x3<0.5)),co.co,co.idx.state,co.idx.error,'un',1);
            elseif h == 3,
                jr(:,h) = cellfun(@(x1,x2,x3) nanmean(x1(x2==2 & x3>0.5)),co.co,co.idx.state,co.idx.error,'un',1);
            end
        end
        jra = [jra;jr];

    end

    subplot(1,2,r)
    bar_custom(jra,'errorbar',1)
    xticklabels({'Explore-like','Exploit-like','Exploit-like (Not optimal)'})
    ylabel('Goal reactivation (rho)')
    title(rois{r})
end



end

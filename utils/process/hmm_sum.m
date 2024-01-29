function out = hmm_sum(data,nHidden,iterNo)
if nargin < 2, nHidden = 2; end
if nargin < 3, iterNo = 1; end

ad = []; for k = 1:length(data), ad = cat(2,ad,data{k}); end
prior0 = ones(nHidden,1);
prior0 = prior0./sum(prior0);
mixmat0 = prior0;
nMixture = 1;

prevPerc = 0;
percCheck = 10;
%tic;

last = 0;
for i = 1:iterNo,
    cPerc = round(i/iterNo*100/percCheck)*percCheck;
    %if cPerc ~= prevPerc, prevPerc = cPerc;  fprintf('fit HMM done %d%% (%d m)\n',cPerc,round(toc/60)); end
    
    transmat0 = mk_stochastic(rand(nHidden,nHidden));
    [mu0, Sigma0] = mixgauss_init(nHidden*nMixture, ad, 'full');
    
    [LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
        mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 1e5, 'verbose', 0,'thresh',1e-15);
    
    LLs(:,i) = LL(end);
    priors(:,i) = prior1;
    trans(:,:,i) = transmat1;
    mus(:,:,i) = mu1;
    sigs(:,:,:,i) = Sigma1;
    mixs(:,i) = mixmat1;

    last = checkPerc(iterNo,i,last,25);
    
end

[~,maxIdx] = max(LLs);

out.LL = LLs(:,maxIdx);
out.prior = priors(:,maxIdx);
out.transmat = trans(:,:,maxIdx);
out.mu = mus(:,:,maxIdx);
out.sig = sigs(:,:,:,maxIdx);
out.mix = mixs(:,maxIdx);

end

function k = findk(data,nHidden)

done = 0;
while ~done,
    k = randperm(length(data),1);
    if size(data{k},2) > nHidden+2, done = 1; end
end

end
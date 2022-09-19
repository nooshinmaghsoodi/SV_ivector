function outputModels = transformModel(devSet, ubmModels)
global params;
outputModels = ubmModels;
transforms = devSet.transforms;
for m = 1 : params.nMonth
    model = outputModels{m};
    trans = transforms{m};
    nState = model.nstates;
    for i = 1 : nState
        offset = trans{i}.offset;
        V = trans{i}.trans;
        model.gmms(i).means = V' * bsxfun(@minus, model.gmms(i).means, offset);
        covars = zeros(size(V, 2), model.gmms(i).nmix);
        for j = 1 : model.gmms(i).nmix
            covars(:, j) = diag(V' * diag(model.gmms(i).covars(:, j)) * V);
        end
        model.gmms(i).covars = covars;
    end
    model = rmfield(model, 'sigma');
    outputModels{m} = model;
end
% do adaptation for each state of each model seperatly
warning('off', 'stats:gmdistribution:FailedToConverge');
for m = 1 : params.nMonth
    model = outputModels{m};
    trans = transforms{m};
    nState = model.nstates;
    for i = 1 : nState
        offset = trans{i}.offset;
        V = trans{i}.trans;
        gmm.mu = model.gmms(i).means;
        gmm.sigma = model.gmms(i).covars;
        gmm.w = exp(model.gmms(i).priors);
        data = V' * bsxfun(@minus, devSet.segmentedFeatures{m}{i}, offset);
%         llk = mean(compute_llk(data, gmm.mu, gmm.sigma, gmm.w'))
%         gmm = mapAdapt({data}, gmm, 19.0, 'mvw');
%         llk = mean(compute_llk(data, gmm.mu, gmm.sigma, gmm.w'))
        [~, gmm] = evalc('gmm_em({data}, double(model.gmms(i).nmix), 15, 1, params.nworkers);');
%         gmm = trainGmmModel(data, double(model.gmms(i).nmix), gmm);
%         llk = mean(compute_llk(data, gmm.mu, gmm.sigma, gmm.w'))
        model.gmms(i).means = gmm.mu;
        model.gmms(i).covars = gmm.sigma;
        model.gmms(i).priors = log(gmm.w);
        fprintf('Finished state %d\n', i);
    end
    model.covar_type = params.covar_type;
    outputModels{m} = model;
    fprintf('Finished month %d\n', m);
end
warning('on', 'stats:gmdistribution:FailedToConverge');
% convert covars to S and create idx_sv
for m = 1 : params.nMonth
    ubm = outputModels{m};
    if (params.covar_type(1) == 'd')
        idx = 1;
        sigma = cell(0, 1);
        for i = 1 : ubm.nstates
            for j = 1 : size(ubm.gmms(i).covars, 2)
                sigma{idx} = ubm.gmms(i).covars(:, j);
                idx = idx + 1;
            end
        end
    else
        idx = 1;
        sigma = cell(0, 1);
        for i = 1 : ubm.nstates
            for j = 1 : size(ubm.gmms(i).covars, 3)
                sigma{idx} = ubm.gmms(i).covars(:, :, j);
                idx = idx + 1;
            end
        end
    end
    outputModels{m}.sigma = sigma;
end

function llk = compute_llk(data, mu, sigma, w)
% compute the posterior probability of mixtures for each frame
post = lgmmprob(data, mu, sigma, w);
llk  = logsumexp(post, 1);

function logprob = lgmmprob(data, mu, sigma, w)
% compute the log probability of observations given the GMM
ndim = size(data, 1);
C = sum(mu.*mu./sigma) + sum(log(sigma));
D = (1./sigma)' * (data .* data) - 2 * (mu./sigma)' * data  + ndim * log(2 * pi);
logprob = -0.5 * (bsxfun(@plus, C',  D));
logprob = bsxfun(@plus, logprob, log(w));

function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
xmax = max(x, [], dim);
y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
ind  = find(~isfinite(xmax));
if ~isempty(ind)
    y(ind) = xmax(ind);
end

function gmm = trainGmmModel(data, nmix, initModel)
option.MaxIter = 100;
S.mu = initModel.mu';
Sigma = zeros(size(data, 1), size(data, 1), nmix);
for i = 1 : nmix
    Sigma(:, :, i) = diag(initModel.sigma(:, i));
end
S.Sigma = Sigma;
S.PComponents = initModel.w;
obj = gmdistribution.fit(data', nmix, 'Regularize', 0.001, 'Options', option);
gmm.mu = obj.mu';
gmm.sigma = obj.Sigma;
gmm.w = obj.PComponents;
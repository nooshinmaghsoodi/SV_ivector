function [N, F, viterbi_log_likelihood, segmentationInfo] = compute_hmm_bw_stats_subspace2...
    (data, transform, hmm, transformedHmm, statFilename)

[N1, F1, viterbi_log_likelihood, segmentationInfo] = compute_hmm_bw_stats(data, hmm);
if (length(segmentationInfo) ~= hmm.nstates)
    error('Length of segmentationInfo must be same as hmm.nstates');
end

[N, F] = expectation(data, transformedHmm, transform, segmentationInfo);

nstates = transformedHmm.nstates;
m = [];
idx_sv = [];
idx = 1;
for i = 1 : nstates
    m = [m; transformedHmm.gmms(i).means(:)]; %#ok<*AGROW>
    dim = size(transformedHmm.gmms(i).means, 1);
    for j = 1 : size(transformedHmm.gmms(i).means, 2)
        idx_sv = [idx_sv; idx * ones(dim, 1)];
        idx = idx + 1;
    end
end

F = F(:);
F = F - N(idx_sv) .* m; % centered first order stats

if (nargin == 5)
	% create the path if it does not exist and save the file
	path = fileparts(statFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	parsave(statFilename, N, F);
end

function [N, F] = expectation(data, transformedHmm, transform, segmentationInfo)
nmix = transformedHmm.gmms(1).nmix;
post = zeros(transformedHmm.nstates * nmix, size(data, 2));
start_idx = 1;
F = [];
for i = 1 : length(segmentationInfo)
    d = data(:, start_idx : start_idx + segmentationInfo(i) - 1);
    d = transform{i}.trans' * bsxfun(@minus, d, transform{i}.offset);  % transform data to new space
    p = lgmmprob(d, transformedHmm.gmms(i).means, transformedHmm.gmms(i).covars, transformedHmm.gmms(i).priors(:));
    llk  = logsumexp(p, 1);
    post_t = exp(bsxfun(@minus, p, llk));
    post((i - 1) * nmix + 1 : i * nmix, start_idx : start_idx + segmentationInfo(i) - 1) = post_t;
    ff = d * post_t';
    F = [F; ff(:)];
    start_idx = start_idx + segmentationInfo(i);
end
N = sum(post, 2);
% F = data * post';

function logprob = lgmmprob(data, mu, sigma, log_w)
% compute the log probability of observations given the GMM
ndim = size(data, 1);
C = sum(mu.*mu./sigma) + sum(log(sigma));
D = (1./sigma)' * (data .* data) - 2 * (mu./sigma)' * data  + ndim * log(2 * pi);
logprob = -0.5 * (bsxfun(@plus, C',  D));
logprob = bsxfun(@plus, logprob, log_w);

function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
xmax = max(x, [], dim);
y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
ind  = find(~isfinite(xmax));
if ~isempty(ind)
    y(ind) = xmax(ind);
end

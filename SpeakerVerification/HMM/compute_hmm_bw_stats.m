function [N, F, viterbi_log_likelihood, segmentationInfo] = compute_hmm_bw_stats(data, hmm, statFilename)
ndim = size(data, 1);
nstates = hmm.nstates;
nmix = hmm.gmms(1).nmix * nstates;
m = [];
for i = 1 : nstates
    m = [m, hmm.gmms(i).means]; %#ok<AGROW>
end
m = reshape(m, ndim * nmix, 1);
idx_sv = reshape(repmat(1 : nmix, ndim, 1), ndim * nmix, 1);

[N, F, viterbi_log_likelihood, segmentationInfo] = expectation(data, hmm);

F = reshape(F, ndim * nmix, 1);
F = F - N(idx_sv) .* m; % centered first order stats

if (nargin == 3)
	% create the path if it does not exist and save the file
	path = fileparts(statFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	parsave(statFilename, N, F);
end

function parsave(fname, N, F) %#ok
save(fname, 'N', 'F')

function [N, F, viterbi_log_likelihood, segmentationInfo] = expectation(data, hmm)
% compute the sufficient statistics
[posts, segmentationInfo, viterbi_log_likelihood] = postprob(data, hmm);
nstates = hmm.nstates;
nmix = hmm.gmms(1).nmix;
post = zeros(nstates * nmix, size(data, 2));
start_idx = 1;
for i = 1 : length(segmentationInfo)
    p = posts{i}(:, start_idx : start_idx + segmentationInfo(i) - 1);
    llk  = logsumexp(p, 1);
    post((i - 1) * nmix + 1 : i * nmix, start_idx : start_idx + segmentationInfo(i) - 1) = exp(bsxfun(@minus, p, llk));
    start_idx = start_idx + segmentationInfo(i);
end
N = sum(post, 2);
F = data * post';

function [post, index, viterbi_log_likelihood] = postprob(data, hmm)
% compute the posterior probability of mixtures for each frame
state_log_likelihood = zeros(hmm.nstates, size(data, 2));
post = cell(1, hmm.nstates);
parfor i = 1 : hmm.nstates
%for i = 1 : hmm.nstates
    post{i} = lgmmprob(data, hmm.gmms(i).means, hmm.gmms(i).covars, hmm.gmms(i).priors(:)); %#ok<PFBNS>
    state_log_likelihood(i, :) = convert_to_state_post(post{i});    
%     llk  = logsumexp(post{i}, 1);
%     post{i} = exp(bsxfun(@minus, post{i}, llk));
end
[index, viterbi_log_likelihood] = segmentation_using_viterbi(hmm, state_log_likelihood);

function state_post = convert_to_state_post(post)
[nmix, nvector] = size(post);
LZERO = -1.0E10;
MINLOGEXP = -23.025851;
LSMALL = -0.5E10;
state_post = LZERO * ones(1, nvector);
for i = 1 : nmix
    for j = 1 : nvector
        x = post(i, j);
        if (state_post(j) < x)
            temp = x;
            diff = state_post(j) - x;
        else
            temp = state_post(j);
            diff = x - state_post(j);
        end
        if (diff < MINLOGEXP)
            if (temp < LSMALL)
                state_post(j) = LZERO;
            else
                state_post(j) = temp;
            end
        else
            state_post(j) = temp + log(1.0 + exp(diff));
        end
    end
end

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

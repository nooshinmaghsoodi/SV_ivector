function transforms = trainFeatureDomainTransforms(devSet)
% train one transform for each model state
global params;
transforms = cell(params.nMonth, 1);
for m = 1 : params.nMonth
    nState = length(devSet.segmentedFeatures{m});
    trans = cell(nState, 1);
    for i = 1 : nState
        data = devSet.segmentedFeatures{m}{i};
%         [V, ~, offset] = trainPCA(data);
        [V, ~, offset] = trainLDA(data, devSet.segmentedFeatureLabels{m}{i}, devSet.unknownIndex);
        trans{i}.trans = V;
        trans{i}.offset = offset;
    end
    transforms{m} = trans;
end

function [V, D, offset] = trainLDA(data, labels, unknownIndex)
data = data(:, labels ~= unknownIndex);
labels = labels(labels ~= unknownIndex);
% minCount = 20;
% spkId = unique(labels);
% selectedIdx = zeros(length(labels), 1);
% for i = 1 : length(spkId)
%     idx = labels == spkId(i);
%     if (sum(idx) >= minCount)
%         selectedIdx(idx) = 1;
%     end
% end
% data = data(:, selectedIdx == 1);
% labels = labels(selectedIdx == 1);
% [V, ~, D] = my_lda(data, labels);
[V, D] = lda(data, labels);
s = cumsum(D); s = s / sum(D);
idx = length(s) - sum(s > 0.95);
% fprintf('%d\n', idx);
V = V(:, 1 : idx);
D = D(1 : idx);
offset = mean(data, 2);

function [V, D, offset] = trainPLDA(data, labels, unknownIndex)
data = data(:, labels ~= unknownIndex);
labels = labels(labels ~= unknownIndex);
% minCount = 20;
% spkId = unique(labels);
% selectedIdx = zeros(length(labels), 1);
% for i = 1 : length(spkId)
%     idx = labels == spkId(i);
%     if (sum(idx) >= minCount)
%         selectedIdx(idx) = 1;
%     end
% end
% data = data(:, selectedIdx == 1);
% labels = labels(selectedIdx == 1);
% [V, ~, D] = my_lda(data, labels);
% [V, D] = lda(data, labels);
% s = cumsum(D); s = s / sum(D);
% idx = length(s) - sum(s > 0.95);
% fprintf('%d\n', idx);
idx = 24;
[~, plda] = evalc('gplda_em(data, labels, idx, 20);');
Phi     = plda.Phi;
Sigma   = plda.Sigma;
M       = plda.M;

T = eye(size(Phi, 2)) + (Phi' / Sigma) * Phi;
T = T \ (Phi' / Sigma);

V = T';
D = [];
offset = M;

function [V, D, offset] = trainPCA(data)
[V, ~, D] = princomp(data');
s = cumsum(D); s = s / sum(D);
idx = length(s) - sum(s > 0.90);
% idx = 24;
% fprintf('%d\n', idx);
V = V(:, 1 : idx);
D = D(1 : idx);
offset = mean(data, 2);

function [V, D, offset] = trainPPCA(data)
idx = 24;
[V, ~, D, ~, noise_variance] = ppca(data', idx);
% s = cumsum(D); s = s / sum(D);
% idx = length(s) - sum(s > 0.95);
% fprintf('%d\n', idx);
offset = mean(data, 2);
% W = V * sqrt(diag(D) - noise_variance * eye(length(D)));
% V = (noise_variance * eye(length(D)) + W' * W) * W';
% V = V';

function [V, D, offset] = trainPPCA2(data)
[V, ~, D, ~, noise_variance] = ppca(data', size(data, 1) - 1);
D(end + 1) = noise_variance;
s = cumsum(D); s = s / sum(D);
idx = length(s) - sum(s > 0.90);
V = V(:, 1 : idx);
noise_variance = mean(D(idx + 1 : end));
D = D(1 : idx);
% fprintf('%d\n', idx);
offset = mean(data, 2);
W = V * sqrt(diag(D) - noise_variance * eye(length(D)));
V = (noise_variance * eye(length(D)) + W' * W) * W';
V = V';
function [mapping, within_covar] = wccn(data, labels)
dim = size(data, 1);
nclass = max(labels);
within_covar = zeros(dim, dim);
for i = 1 : nclass
    inx_i = find(labels == i);
    X_i = data(:, inx_i);
    mean_Xi = mean(X_i, 2);
    X_i = bsxfun(@minus, X_i, mean_Xi);
    within_covar = within_covar + (X_i * X_i') / length(inx_i);% + 0.001 * eye(size(X_i, 1));
end
within_covar = within_covar / nclass;
wccnTrans = chol(within_covar ^ -1, 'lower');
mapping.W = wccnTrans;
mapping.mean = mean(data, 2);
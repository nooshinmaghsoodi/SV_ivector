function mapping = lda_dr(data, labels)
data_dim = size(data, 1);

% Make sure data is zero mean
mapping.mean = mean(data, 2);
data = bsxfun(@minus, data, mapping.mean);

% Make sure labels are nice
[classes, ~, labels] = unique(labels);
nc = length(classes);

% Intialize Sw
Sw = zeros(data_dim);
mx = zeros(nc, data_dim);
% Sum over classes
for i = 1 : nc
    % Get all instances with class i
    cur_X = data(:, labels == i)';
    mx(i, :) = mean(cur_X, 1);
    % Update within-class scatter
    C = cov(cur_X, 1);
    p = 1;
% 	p = size(cur_X, 1) / (length(labels) - 1);
    Sw = Sw + (p * C);
end

% Compute total covariance matrix
% St = cov(data);
% Compute between class scatter 
% Sb = St - Sw;
Sb = cov(mx, 1);
Sb(isnan(Sb)) = 0; Sw(isnan(Sw)) = 0;
Sb(isinf(Sb)) = 0; Sw(isinf(Sw)) = 0;

no_dims = nc - 1;

% Perform eigendecomposition of inv(Sw)*Sb
[W, lambda] = eig(Sb, Sw);

% Sort eigenvalues and eigenvectors in descending order
lambda(isnan(lambda)) = 0;
[lambda, ind] = sort(diag(lambda), 'descend');
W = W(:, ind(1 : min(no_dims, data_dim)));

% Store mapping for the out-of-sample extension
mapping.W = W;
mapping.val = lambda;
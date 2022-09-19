function mapping = pca(data)
mapping.mean = mean(data, 2);
data = bsxfun(@minus, data, mapping.mean);

% Compute covariance matrix
if (size(data, 1) < size(data, 2))
    C = cov(data');
else
    C = data' * data / size(data, 1); % if N > D, we better use this matrix for the eigendecomposition
end
% Perform eigendecomposition of C
C(isnan(C)) = 0;
C(isinf(C)) = 0;
[W, lambda] = eig(C);

% Sort eigenvectors in descending order
[lambda, ind] = sort(diag(lambda), 'descend');
W = W(:, ind) * diag(1 ./ sqrt(lambda));

% Store information for out-of-sample extension
mapping.W = W;
mapping.lambda = lambda;
    
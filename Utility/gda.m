function mappedX = gda(data, labels, varargin)
%GDA Perform Generalized Discriminant Analysis
%
%	mappedX = gda(data, labels)
%	mappedX = gda(data, labels, kernel)
%	mappedX = gda(data, labels, kernel, param1)
%	mappedX = gda(data, labels, kernel, param1, param2)
%
% Perform Generalized Discriminant Analysis. GDA or Kernel LDA is the 
% nonlinear generalization of LDA by means of the kernel trick. data is the
% data on which to perform GDA, labels are the corresponding labels.
% The value of kernel determines the used kernel. Possible values are 'linear',
% 'gauss', 'poly', 'subsets', or 'princ_angles' (default = 'gauss'). For
% more info on setting the parameters of the kernel function, type HELP
% GRAM.
% The function returns the locations of the embedded trainingdata in 
% mappedX.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.7.2b.
% The toolbox can be obtained from http://homepage.tudelft.nl/19j49
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten, 2010
% University California, San Diego / Delft University of Technology

kernel = 'gauss';
param1 = 1;
param2 = 0;
if (~isempty(varargin) && ischar(varargin{1})), kernel = varargin{1}; end 
if (length(varargin) > 1 && isnumeric(varargin{2})), param1 = varargin{2}; end
if (length(varargin) > 2 && isnumeric(varargin{3})), param2 = varargin{3}; end

% Make sure labels are nice
[~, ~, labels] = unique(labels, 'rows');

% Get dimensions
n = size(data, 2);
nclass = max(labels);

% Sort data according to labels
[~, ind] = sort(labels);
labels = labels(ind);
data = data(:, ind);

% Compute kernel matrix
K = gram(data, data, kernel, param1, param2);

% Compute centering matrix
ell = size(data, 2);
D = sum(K) / ell;
E = sum(D) / ell;
J = ones(ell, 1) * D;
K = K - J - J' + E * ones(ell);

% Perform eigenvector decomposition of kernel matrix (Kc = P * gamma * P')
K(isnan(K)) = 0;
K(isinf(K)) = 0;
% [P, gamma] = eig(K); %change by hsn (add 'nobalance')
[P, gamma] = eig(K, 'nobalance');

if (size(P, 2) < n)
    error('Singularities in kernel matrix prevent solution.');
end

% Sort eigenvalues and vectors in descending order
[gamma, ind] = sort(diag(gamma), 'descend');
P = P(:, ind);

% Remove eigenvectors with relatively small value
minEigv = max(gamma) / 1e5;
ind = find(gamma > minEigv);
P = P(:, ind);
gamma = gamma(ind);
rankK = length(ind);

% Recompute kernel matrix
K = P * diag(gamma) * P';

% Construct diagonal block matrix W
W = [];
for i = 1 : nclass
    num_data_class = length(find(labels == i));
    W = blkdiag(W, ones(num_data_class) / num_data_class);
end

% Determine target dimensionality of data 
no_dims = min(rankK, nclass);

% Perform eigendecomposition of matrix (P' * W * P)
[Beta, lambda] = eig(P' * W * P, 'nobalance'); %with hsn
% 	[Beta, lambda] = eig(P' * W * P);
lambda = diag(lambda);

% Sort eigenvalues and eigenvectors in descending order
[~, ind] = sort(lambda, 'descend');
Beta = Beta(:, ind(1 : no_dims));

% Compute final embedding mappedX
mappedX = P * diag(1 ./ gamma) * Beta;

% Normalize embedding
for i = 1 : no_dims
    mappedX(:,i) = mappedX(:,i) / sqrt(mappedX(:,i)' * K * mappedX(:,i));
end
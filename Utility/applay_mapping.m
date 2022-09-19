function data_out = applay_mapping(data, mapping, no_dims)
data_dim = size(data, 1);
if (~exist('no_dims', 'var'))
    no_dims = data_dim;
end
switch (mapping.name)
    case {'LDA', 'PCA'}
        data_out = bsxfun(@minus, data, mapping.mean);
        data_out = mapping.W(:, 1 : no_dims)' * data_out;
    case 'WCCN'
        mapping.mean = mean(data, 2);
        data = bsxfun(@minus, data, mapping.mean);
        data_out = mapping.W' * data;
    case 'GDA'
        K = gram(mapping.trainData, data, 'poly', 1, 7);
        data_out = mapping.W(:, 1 : no_dims)' * K;
    otherwise
        error('Unknown method name.');
end
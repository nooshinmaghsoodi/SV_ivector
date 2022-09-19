function mapping = compute_mapping(method, data, labels, covMat)
global params;
switch (method)
    case 'LDA_DR'
        % Run LDA on labeled dataset
        mapping = lda_dr(data, labels);%lda_dr(data, labels);
        mapping.name = 'LDA';
    case 'LDA_MSR'
        % Run LDA on labeled dataset
        mapping = lda(data, labels);%lda_dr(data, labels);
        mapping.name = 'LDA';
    case 'LDA_DRF'
        % Run LDA on labeled dataset
        mapping = lda_dr_f(data, labels);
        mapping.name = 'LDA';
    case 'UP_LDA'
        % Run LDA on labeled dataset
        mapping = up_lda_f(data, labels, covMat);
        mapping.name = 'LDA';
    case 'UN-NORM'
        % Run LDA on labeled dataset
        [~, within_cov] = wccn(data, labels);
        mapping = un_norm(covMat, within_cov, params.use_within);
        mapping.name = 'WCCN';
%    case 'UN-NORM-WCCN'
%        % Run LDA on labeled dataset
%        [~, within_cov] = wccn(data, labels);
%        mapping = un_norm(covMat, within_cov, params.use_within);
%        mapping.name = 'WCCN';
    case 'GDA'
        % Run LDA on labeled dataset
%         data = data(:, 1 : 10 : end);
%         labels = labels(1 : 10 : end);
        mapping.W = gda(data, labels, 'poly', 1, 7);
        mapping.name = 'GDA';
        mapping.trainData = data;
    case 'PCA'
        % Compute PCA mapping
        mapping = pca(data);
        mapping.name = 'PCA';
    case 'WCCN'
        % Run LDA on labeled dataset
        mapping = wccn(data, labels);
        mapping.name = 'WCCN';
    otherwise
        error('Unknown method.');
end

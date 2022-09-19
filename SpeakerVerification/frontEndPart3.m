function outputSets = frontEndPart3(inputSets)
%%
global params;
digitcount = 10;
outputSets = inputSets;
% langId = unique(inputSets.train.langs);
% numLangs = length(langId);
configs = strsplit(params.paramPrefix, '_');
for c = 1 : length(configs)
    temp = strsplit(configs{c}, '-');
    trans = lower(temp{1});
    transParams = '';
    if (length(temp) == 2), transParams = temp{2}; end
    if (strcmp(trans, 'whiten')), trans = 'pca'; transParams = num2str(size(ivecs, 1)); end
    switch (trans)
        % LDA Part
        case 'lda'
            if (isempty(transParams)), error('LDA transform need ldaDim.'); end
            for i = 1 : length(outputSets)
                ldaMaps = trianLdaModels(outputSets{i}, 'LDA_DR');
                highestIdx = getHighestTrainingIdx(outputSets{i}.gender);
                ldaDim = min(str2double(transParams),  highestIdx - 1); %2 * highestIdx
                outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
            end
        case 'ldamsr'
            if (isempty(transParams)), error('LDA transform need ldaDim.'); end
            for i = 1 : length(outputSets)
                ldaMaps = trianLdaModels(outputSets{i}, 'LDA_MSR');
                highestIdx = getHighestTrainingIdx(outputSets{i}.gender);
                ldaDim = min(str2double(transParams),  highestIdx - 1); %2 * highestIdx
                outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
            end
        case 'ldaf'
            if (isempty(transParams)), error('LDA transform need ldaDim.'); end
            for i = 1 : length(outputSets)
                ldaMaps = trianLdaModels(outputSets{i}, 'LDA_DRF');
                ldaDim = min(str2double(transParams), size(outputSets{i}.ivectors{1}, 1));
                outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
            end
        case 'ldafgi'
            if (isempty(transParams)), error('LDA transform need ldaDim.'); end
            ldaMaps = trianLdaModels2(outputSets, 'LDA_DRF');
            ldaDim = min(str2double(transParams), size(outputSets{1}.ivectors{1}, 1));
            for i = 1 : length(outputSets)
                outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
            end
        % WCCN Part
        case 'wccn'
            for i = 1 : length(outputSets)
                wccnMaps = trianLdaModels(outputSets{i}, 'WCCN');
                outputSets{i}.ivectors = applayMaps(outputSets{i}, wccnMaps);
            end
        case 'pca'      %% PCA part
            if (isempty(transParams)), error('PCA transform need numOfPrincomp.'); end
            numOfPrincomp = str2double(transParams);
            for i = 1 : length(outputSets)
                pcaMaps = trianLdaModels(outputSets{i}, 'PCA');
                outputSets{i}.ivectors = applayMaps(outputSets{i}, pcaMaps, numOfPrincomp);
            end
        case 'RemoveLessThan'       %% Remove Less Than minDuration Sec
            if (isempty(transParams)), error('RemoveLessThan need minDuration.'); end
            minDuration = str2double(transParams);
            newIdxs = devDurations > minDuration;
            outputSets.development.ivecs = outputSets.development.ivecs(newIdxs, :);
            devDataLabel = devDataLabel(newIdxs, 1);
        case 'normlen'          %% Length normalization
            % Project all i-vectors into unit sphere
            for i = 1 : length(outputSets)
                for j=1:digitcount
                    outputSets{i}.ivectors{j} = normalizeLength(outputSets{i}.ivectors{j}, 2);
                end
            end
        case 'uplda'          
            if (isempty(transParams)), error('LDA transform need ldaDim.'); end
            for i = 1 : length(outputSets)
                ldaMaps = trianUPLdaModels(outputSets{i}, 'UP_LDA');
            
                ldaDim = min(str2double(transParams), size(outputSets{i}.ivectors{1}, 1));
%                 highestIdx = getHighestTrainingIdx(outputSets{i}.gender);
%                 ldaDim = min(str2double(transParams),  highestIdx - 1);
                outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
            end
        case 'unnorm'         
        %% replace with corrected code 
           for i = 1 : length(outputSets)
               ldaMaps = trianUPLdaModels(outputSets{i}, 'UN-NORM');
               ldaDim = min(str2double(transParams), size(outputSets{i}.ivectors{1}, 1));
               outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
           end
        %%
%             if (isempty(transParams)), error('LDA transform need ldaDim.'); end
%             for i = 1 : length(outputSets)
%                 ldaMaps = trianLdaModels(outputSets{i}, 'LDA_DRF');
%                 ldaDim = min(str2double(transParams), size(outputSets{i}.ivectors{1}, 1));
%                 outputSets{i}.ivectors = applayMaps(outputSets{i}, ldaMaps, ldaDim);
%             end
    end
end

function lda_mapping = trianLdaModels(inputSet, transKind)
digitcount = 10;
highestIdx = getHighestTrainingIdx(inputSet.gender);
lda_mapping = cell(digitcount, 1);
for i = 1 : digitcount
    trainData = [];
    trainLabel = [];
    for j = 1 :  highestIdx 
        idx = inputSet.id2index(:, :, j);
        idx = idx(:);
        idx = idx(idx ~= 0);
        ivs_idx = find(ismember( inputSet.ivecId{i}, idx));
        ivs = inputSet.ivectors{i}(:, ivs_idx);
        trainData = [trainData, ivs]; %#ok<*AGROW>
        trainLabel = [trainLabel, j * ones(1, size(ivs, 2))];
    end
    lda_mapping{i} = compute_mapping(transKind, trainData, trainLabel);
end

function lda_mapping = trianUPLdaModels(inputSet, transKind)
digitcount = 10;
lda_mapping = cell(digitcount, 1);
for i = 1 : digitcount
    trainData = [];
    trainLabel = [];
    highestIdx = getHighestTrainingIdx(inputSet.gender);
        for j = 1 :  highestIdx 
            idx = inputSet.id2index(:, :, j);
            idx = idx(:);
            idx = idx(idx ~= 0);
            ivs_idx = find(ismember( inputSet.ivecId{i}, idx));
            ivs = inputSet.ivectors{i}(:, ivs_idx);
            trainData = [trainData, ivs]; %#ok<*AGROW>
            trainLabel = [trainLabel, j * ones(1, size(ivs, 2))];
        end
    lda_mapping{i} = compute_mapping(transKind, trainData, trainLabel, inputSet.covMat{i});
end
%%
function lda_mapping = trianLdaModels2(inputSets, transKind)
digitcount = 10;
lda_mapping = cell(digitcount, 1);
for i = 1 : digitcount
    trainData = [];
    trainLabel = [];
    jj = 1;
    for s = 1 : length(inputSets)
        highestIdx = getHighestTrainingIdx(inputSets{s}.gender);
        for j = 1 : highestIdx
            idx = inputSets{s}.id2index(:, :, j);
            idx = idx(:);
            idx = idx(idx ~= 0);
            ivs_idx = find(ismember( inputSets{s}.ivecId{i}, idx));
            ivs = inputSets{s}.ivectors{i}(:, ivs_idx);
            trainData = [trainData, ivs]; %#ok<*AGROW>
            trainLabel = [trainLabel, jj * ones(1, size(ivs, 2))];
            jj = jj + 1;
        end
    end
    lda_mapping{i} = compute_mapping(transKind, trainData, trainLabel);
end

function ivectors = applayMaps(inputSet, maps, dim)

digitcount = 10;
if (nargin < 3)
    dim = size(inputSet.ivectors, 1);
end
ivectors = cell(digitcount,1);
for i = 1 : length(maps)
    %ivectors = zeros(dim, size(inputSet.ivectors{i}, 2));
    ivectors{i} = applay_mapping(inputSet.ivectors{i}, maps{i}, dim);
end
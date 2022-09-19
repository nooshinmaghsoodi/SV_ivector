function [normalizationParams, nearestIndexes] = calculateNormalizationParams(inputSet, modelsId2Index)

modelsSenNum = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for i = 1 : size(modelsId2Index, 1)
    for j = 1 : size(modelsId2Index, 2)
        if (modelsId2Index(i, j) ~= 0)
            modelsSenNum(modelsId2Index(i, j)) = i;
        end
    end
end
impModels = inputSet.imposterModels;
nearestIndexes = [];%cell(params.nMonth, 1);
keys = modelsSenNum.keys;
n_models = length(keys);
zMean = zeros(n_models, 1);
zStd = zeros(n_models, 1);
for i = 1 : n_models
    senNum = modelsSenNum(keys{i});
    imposterVectors = inputSet.ivectors(:, inputSet.spkLabels <= 94 & inputSet.sentenceId == senNum);
    zScores = inputSet.models(:, keys{i})' * imposterVectors;
%     impScores = impModels{senNum}' * imposterVectors;
%     zScores = (zScores - mean(impScores)) ./ std(impScores);
    zScores = sort(zScores, 'descend');
    zScores = zScores(1 : 300);
    zMean(i) = mean(zScores);
    zStd(i) = std(zScores);
end
% nearestIndexes{m} = localIndexes;
normalizationParams.mean = zMean;
normalizationParams.std = zStd;
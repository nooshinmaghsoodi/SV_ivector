function [dig_modelIvectors, imposterModels] = makeModelsIvectorsPart3(inputSet, modelsIndexes)
global params;
imposterModels = trianImposterModels(inputSet);
n_models = size(modelsIndexes, 1);
dig_modelIvectors =cell (10,1);
% goodModels = ones(n_models, 1);
% llIdx = inputSet.logLikelihoods > (mean(inputSet.logLikelihoods) - 3 * std(inputSet.logLikelihoods));
for i=1:10
    modelIvectors = zeros(size(inputSet.ivectors{1}, 1), n_models);
    for model = 1 : n_models
        idx = modelsIndexes(model, :);
        %sessId = idx(1);
        idx = idx (3:end);
        if (find(idx == 0))
            fprintf('Warning, models indexes is zero, model : %d\n', model);
            idx = idx(idx ~= 0);
        end
        ivs_idx = find(ismember( inputSet.ivecId{i}, idx));
        ivs = inputSet.ivectors{i}(:, ivs_idx);
        modelIvectors(:, model) = mean(ivs, 2);
    end
    if (params.normalizeModelVectors)
        modelIvectors = normalizeLength(modelIvectors, 2);
    end
    dig_modelIvectors{i} = modelIvectors;
end


function imposterModels = trianImposterModels(inputSet)
global params;
highestIdx = eval(['params.subsetsSize.' inputSet.gender]);
highestIdx = highestIdx(1);% + highestIdx(2);
imposterModels = cell(10, 1);
for i = 1 : 10
    models = zeros(size(inputSet.ivectors{i}, 1), highestIdx);
    for j = 1 : highestIdx
        idx = inputSet.id2index(:, :, j);
        idx = idx(:);
        idx = idx(idx ~= 0);
        ivs_idx = find(ismember( inputSet.ivecId{i}, idx));
        ivs = inputSet.ivectors{i}(:, ivs_idx);
        models(:, j) = mean(ivs, 2);
    end
    if (params.normalizeModelVectors)
        models = normalizeLength(models, 2);
    end
    imposterModels{i} = models;
end
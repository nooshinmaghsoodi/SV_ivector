function [segmentedFeatures, segmentedFeatureLabels] = segmentDataSet(inputSet, ubmModels)
global params;
prefixes = getPrefixes();
outputDir = [prefixes.ivectorOutputDir 'Sementation\'];
if (~exist(outputDir, 'dir')), mkdir(outputDir); end
fprintf('Segmenting features for %s...\n', inputSet.name);
segmentation = cell(params.nMonth, 1);
for m = 1 : params.nMonth
    fileName = [outputDir inputSet.name '_' num2str(m) '.mat'];
    if (~exist(fileName, 'file'))
        ubm = ubmModels{m};
        features = inputSet.features{m};
        segmentationInfo = zeros(ubm.nstates, length(features));
        parfor file = 1 : length(features)
            [~, ~, ~, segmentationInfo(:, file)] = compute_hmm_bw_stats(features{file}, ubm);
        end
        save(fileName, 'segmentationInfo');
        fprintf('Finished month %d\n', m);
    else
        load(fileName);
    end
    segmentation{m} = segmentationInfo;
end
fprintf('Segmenting features for %s finished.\n', inputSet.name);
segmentedFeatures = cell(params.nMonth, 1);
segmentedFeatureLabels = cell(params.nMonth, 1);
for m = 1 : params.nMonth
    nState = ubmModels{m}.nstates;
    features = inputSet.features{m};
    labels = inputSet.labels{m};
    counts = sum(segmentation{m}, 2);    
    stateFeatures = cell(nState, 1);
    stateLabels = cell(nState, 1);
    for i = 1 : nState
        stateFeatures{i} = zeros(params.featureDim, counts(i));        
        stateLabels{i} = zeros(counts(i), 1);
    end
    idx = ones(nState, 1);
    for f = 1 : length(features)
        fea = features{f};
        startIdx = 1;
        info = segmentation{m}(:, f);
        for i = 1 : nState
            endIdx = startIdx + info(i) - 1;
            stateFeatures{i}(:, idx(i) : idx(i) + info(i) - 1) = fea(:, startIdx : endIdx);
            stateLabels{i}(idx(i) : idx(i) + info(i) - 1) = labels(f) * ones(info(i), 1);
            startIdx = startIdx + info(i);
            idx(i) = idx(i) + info(i);
        end
    end
    segmentedFeatureLabels{m} = stateLabels;
    segmentedFeatures{m} = stateFeatures;
end
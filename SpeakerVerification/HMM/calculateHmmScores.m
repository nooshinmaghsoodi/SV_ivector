function inputSet = calculateHmmScores(inputSet, modelSet, ubmModels)
global params;
prefixes = getPrefixes();
scoreName = [inputSet.name '_' modelSet.name];
scoresOutputDir = [prefixes.modelsOutputDir 'Scores' filesep];
if (~exist(scoresOutputDir, 'dir')), mkdir(scoresOutputDir); end
scoresFileName = [scoresOutputDir scoreName '.mat'];
if (~exist(scoresFileName, 'file'))
    fprintf('Calculating scores for %s...\n', inputSet.name);
    allScores = cell(params.nMonth, 1);
    for m = 1 : params.nMonth
        ubm = ubmModels{m};
        features = inputSet.features{m};
        models = modelSet.models{m};
        temp = cell(length(features), 1);
        parfor file = 1 : length(features)
            [~, ~, ubmScore] = compute_hmm_bw_stats(features{file}, ubm);
            scoTemp = zeros(length(models), 1);
            for i = 1 : length(models)
                [~, ~, spkScore] = compute_hmm_bw_stats(features{file}, models{i});
                scoTemp(i) = spkScore - ubmScore;
            end
            temp{file} = scoTemp;
        end
        scores = zeros(length(models), length(features));
        for file = 1 : length(features)
            for i = 1 : length(models)
                scores(i, file) = temp{file}(i);
            end
        end
        allScores{m} = scores;
        fprintf('Finished month %d\n', m);
    end
    save(scoresFileName, 'allScores');
    fprintf('Calculating scores for %s finished.\n', inputSet.name);
else
    fprintf('Loading scores for %s...\n', inputSet.name);
    load(scoresFileName);
    fprintf('Loading scores for %s finished.\n', inputSet.name);
end
if (~isfield(inputSet, 'scores'))
    inputSet.scores = containers.Map;
end
inputSet.scores(modelSet.name) = allScores;
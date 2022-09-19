function [hmms, statesAlignments, modelsIdx] = getSentenceHmms(ubmModels)
transMap = getFilesTranscribtions();
hmms = cell(transMap.Count, 1);
statesAlignments = cell(transMap.Count, 1);
map = containers.Map;
for i = 1 : length(ubmModels)
    map(ubmModels{i}.name) = i;
end
modelsIdx = convertTrans2ModelsIdx(transMap, map);
keys = transMap.keys;
for i = 1 : transMap.Count
    [hmms{str2double(keys{i})}, statesAlignments{str2double(keys{i})}] = ...
        criateSentenceHmm(ubmModels, modelsIdx{str2double(keys{i})}, keys{i});
end

function modelsIdx = convertTrans2ModelsIdx(transMap, map)
modelsIdx = cell(transMap.Count, 1);
keys = transMap.keys;
for i = 1 : transMap.Count
    parts = strsplit(transMap(keys{i}));
    idx = zeros(1, length(parts));
    for j = 1 : length(parts)
        idx(j) = map(parts{j});
    end
    modelsIdx{str2double(keys{i})} = [map('SIL'), idx, map('SIL')];
end

function [hmm, statesAlignment] = criateSentenceHmm(ubmModels, modelsIdx, name)
hmm.name = name;
nstates = 0;
sigmaSize = 0;
for i = 1 : length(modelsIdx)
    nstates = nstates + ubmModels{modelsIdx(i)}.nstates;
    sigmaSize = sigmaSize + size(ubmModels{modelsIdx(i)}.sigma, 2);
end
statesAlignment = zeros(1, nstates);
hmm.nstates = nstates;
hmm.gmms = repmat(ubmModels{1}.gmms(1), 1, nstates);
hmm.emission_type = ubmModels{1}.emission_type;
hmm.start_prob = -inf(1, nstates); hmm.start_prob(1) = 0;
hmm.transmat = -inf(nstates);
hmm.end_prob = -inf(1, nstates);
hmm.sigma = zeros(size(ubmModels{1}.sigma, 1), sigmaSize);
hmm.covar_type = ubmModels{1}.covar_type;
startIdx = 1;
sigmaStartIdx = 1;
for i = 1 : length(modelsIdx)
    idx = modelsIdx(i);
    model = ubmModels{idx};
    fromToIdx = startIdx : startIdx + model.nstates - 1;
    statesAlignment(fromToIdx) = (modelsIdx(i) - 1) * model.nstates + 1 : modelsIdx(i) * model.nstates;
    hmm.gmms(fromToIdx) = model.gmms;
    hmm.transmat(fromToIdx, fromToIdx) = model.transmat;
    if (i < length(modelsIdx))
        hmm.transmat(fromToIdx(end), fromToIdx(end) + 1) = model.end_prob(end);
    end
    hmm.sigma(:, sigmaStartIdx : sigmaStartIdx + size(model.sigma, 2) - 1) = model.sigma;
    startIdx = startIdx + model.nstates;
    sigmaStartIdx = sigmaStartIdx + size(model.sigma, 2);
end
hmm.end_prob(end) = model.end_prob(end);

function [zScores, normRe, imposterIndexes] = getSpkAndImposterModelsForBaseline(trainSet, devSet, monthIndex, modelIndex)
trainScores = trainSet.scores(devSet.name);
scores = trainScores{monthIndex}(:, trainSet.labels{monthIndex} == modelIndex);
[~, idx] = sort(mean(scores, 2), 'descend');
imposterIndexes = idx(1 : 50);

devScores = devSet.scores(trainSet.name);
scores = devScores{monthIndex};
[~, idx] = sort(scores, 'descend');
zScores = scores(idx(1 : 500));

devScores = devSet.scores(devSet.name);
scores = devScores{monthIndex};
normRe = scores(imposterIndexes, idx(1 : 500));
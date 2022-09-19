function scoringPart3(inputSet, trials, trialContent, modelsId2Index)
global params;
fprintf('Scoring the verification trials for %s ...\n', inputSet.gender);
% if strcmp(inputSet.gender, 'male')
%     trials = trials(1 : 349011, :);
% end
trueScores = [];
falseScores = [];
targetTrials = trials(trials(:, 4) == 1, 1 : 3);
targetContent = trialContent (trials(:, 4) == 1);
[modelsIdx, ~, idx] = unique(targetTrials(:, 1));
impModels = inputSet.imposterModels;
transMap = getPart3Id2SentenceMap();
for i = 1 : length(modelsIdx)
    ii = targetTrials(idx == i, 3);
    ii_session = targetTrials(idx == i, 2);
    ii_content = targetContent(idx == i);
    if (find(ii == 0))
        fprintf('Warning, trial indexes is zero, model : %d\n', modelsIdx(i));
        ii = ii(ii ~= 0);
    end
    nzId = modelsId2Index (modelsIdx(i), ii_session);
    nzId = find (nzId ~= 0);
    ii_scores = zeros(1, length(nzId));
    for sent = nzId %1:length(ii_content)
        ii_content_sent = transMap((ii_content{sent}));
        ii_content_sent = strrep(ii_content_sent, '0', '10');
        digits = strsplit(ii_content_sent, '-');
        
        sentScore = 0;
        for dig = 1:length(digits)
            ivecInd = find(inputSet.ivecId{str2double(digits(dig))} == ii(sent));
            ii_iv = inputSet.ivectors{dig}(:, ivecInd);
            modelId = modelsId2Index (modelsIdx(i), ii_session(sent));            
            digScore = inputSet.models{dig}(:, modelId)' * ii_iv;
            impScores = impModels{dig}' * ii_iv;
            digScore = (digScore - mean(impScores)) / std(impScores);
            sentScore = sentScore + digScore;
        end
        ii_scores(sent) = sentScore;
    end  
    trueScores = [trueScores; ii_scores']; %#ok<AGROW>
end
nontargetTrials = trials(trials(:, 4) == 3, 1 : 3);
[modelsIdx, ~, idx] = unique(nontargetTrials(:, 1));
nontargetContent = trialContent (trials(:, 4) == 3);
for i = 1 : length(modelsIdx)
    ii = nontargetTrials(idx == i, 3);
    ii_session = nontargetTrials(idx == i, 2);
    ii_content = nontargetContent(idx == i);
    if (find(ii == 0))
        fprintf('Warning, trial indexes is zero, model : %d\n', modelsIdx(i));
        ii = ii(ii ~= 0);
    end
    nzId = modelsId2Index (modelsIdx(i), ii_session);
    nzId = find (nzId ~= 0);
    ii_scores = zeros(1, length(nzId));
    for sent = nzId %1:length(ii_content)
        ii_content_sent = transMap((ii_content{sent}));
        ii_content_sent = strrep(ii_content_sent, '0', '10');
        digits = strsplit(ii_content_sent, '-');
        sentScore = 0;
        for dig = 1:length(digits)
            ivecInd = find(inputSet.ivecId{str2double(digits(dig))} == ii(sent));
            ii_iv = inputSet.ivectors{dig}(:, ivecInd);            
            modelId = modelsId2Index (modelsIdx(i), ii_session(sent));
            digScore = inputSet.models{dig}(:, modelId)' * ii_iv;
            impScores = impModels{dig}' * ii_iv;
            digScore = (digScore - mean(impScores)) / std(impScores);
            sentScore = sentScore + digScore;
        end
        ii_scores(sent) = sentScore;
    end  
    falseScores = [falseScores; ii_scores']; %#ok<AGROW>
end
scores = [trueScores; falseScores];
score_det{1} = scores;
score_det{2} = length(trueScores);
score_det{3} = length(falseScores);
save(['scores/' params.feaType '_' inputSet.gender '_' params.paramPrefix '.mat'], 'score_det');


% figure
[eer, minDcf08, minDcf10] = compute_eer(scores, [ones(length(trueScores), 1); zeros(length(falseScores), 1)], true); % IV averaging
prefixes = getPrefixes();
rocPath = [prefixes.ivectorOutputDir prefixes.paramPrefix filesep 'roc.fig'];
% saveas(gcf, rocPath, 'fig');
fprintf('Test finished, EER : %f, MinDCF08 : %f, , MinDCF10 : %f\n', eer, minDcf08, minDcf10);
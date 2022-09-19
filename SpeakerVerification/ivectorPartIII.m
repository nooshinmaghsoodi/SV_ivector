% clc;
addpath('HMM');
addpath(genpath('Utilities'));
addpath(['..' filesep 'Utility']);
addpath(['..' filesep 'MSRIdentityToolkit']);
global params;
setParams();
params.useHmm = true;   % for using GMM change this to false

params.paramPrefix = 'unnorm-300_NormLen_ldaf-300'; % lda: regular LDA, uplda: LDA with uncertainty propagation, unnorm: uncertainty normalizatin _unnorm-300_NormLen_ldaf
params.normalizeModelVectors = true;
%% Step0: Opening MATLAB pool 
%if (matlabpool('size') <= 0)
%   matlabpool(params.nworkers);
%end
sets = cell(1, 1);
if (params.fusion)
    sets{1}.gender = 'male';
    display ('Computing fusion scoring ...');
    for i = 1 : length(sets)
      fusionScoring(sets{i});
    end        
end
parpool(params.nworkers);
%% Step1: Loading all datasets
display (' feature loading started ...');
if (~params.featureExtracted) 
    display (' feature extraction started ...');
    extractAllFeatures();
end

if (~exist('sets', 'var'))
    genders = getGenders();
    sets = cell(length(genders), 1);
    if (params.cmvn) 
        if ( ~params.featureTransformed)
            for i = 1 : length(genders)
                sets{i} = loadGenderSet(genders{i}, false);
            end
            display (' feature transformation started ...');
            params.featureDim
            transformFeatures(sets, params.feaDir, params.feaType, params.featureDim);
            for i = 1 : length(genders)
                sets{i} = loadGenderSet(genders{i}, true);
            end
        else 
            for i = 1 : length(genders)
                sets{i} = loadGenderSet(genders{i}, true);
            end
        end
    else
        for i = 1 : length(genders)
            sets{i} = loadGenderSet(genders{i}, false);
        end
    end
end
display (' feature loading finished.');
%% Step2: Training the UBM's
if (~exist('ubmModels', 'var'))
   [ubmModels, overallModel] = trainUbmModels();
end
%%segmentationUsingHmm(sets, ubmModels);
%% Step3: Learning the total variability subspaces from background data
if (~exist('T', 'var'))
    T = trainPart3TVS(sets, ubmModels, overallModel);
end

%% Step4: Extracting all i-vectors
for i = 1 : length(sets)
  [sets{i}.ivectors, sets{i}.logLikelihoods, sets{i}.covMat, sets{i}.ivecId] = extractIvectorsPart3(sets{i}, T, ubmModels);
end
if (params.fusion)
    display ('Computing fusion scoring ...');
    for i = 1 : length(sets)
      fusionScoring(sets{i});
    end        
else
    %% Step5: Training and doing all necessary transforms
    display ('Loading trials...');
    modelsIndexes = cell(length(sets), 1);
    modelsId2Index = cell(length(sets), 1);
    evalTrials = cell(length(sets), 1);
    evalTrialContent = cell(length(sets), 1);
    for i = 1 : length(sets)
       [modelsIndexes{i}, modelsId2Index{i}] = loadModelsIdxPart3(sets{i}, '3seq10');
       %[evalTrials{i}, evalTrialContent{i}] = loadTrialsPart3(sets{i}, 'seq5_testeval');
       [evalTrials{i}, evalTrialContent{i}] = loadKennyTrialsPart3(sets{i}, 'seq5_testeval');
       
    end
    display ('Transformations...');
    transformedSets = frontEndPart3(sets);
    
    %% Step6: Extracting models i-vectors
    
    display ('Extracting models i-vectors...');
    for i = 1 : length(transformedSets)
       [transformedSets{i}.models, transformedSets{i}.imposterModels] = ...
           makeModelsIvectorsPart3(transformedSets{i}, modelsIndexes{i});
    end
    %% Step7: Calculating normalization parameters
    % [normalizationParams, nearestIndexes] = calculateNormalizationParams(transformedSets{1}, modelsId2Index);
    
    %% Step8: Scoring the verification trials and Computing the EER and plotting the DET curve
    
    for i = 1 : length(transformedSets)
       scoringPart3(transformedSets{i}, evalTrials{i}, evalTrialContent{i}, modelsId2Index{i});
    end
end
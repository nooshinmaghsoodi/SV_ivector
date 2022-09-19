function [digIvectors, logLikelihoods, covMats, digFullId] = extractIvectorsPart3(inputSet, T, ubmModels, transforms, transformedModels)
global params;
useHmm = params.useHmm;
subspaceHmm = params.subspaceHmm;
saveCov = params.saveCov;
if (subspaceHmm && ~useHmm)
    error('For subspace processing useHmm must be true.');
end
prefixes = getPrefixes();
ivectorOutputDir = prefixes.ivectorOutputDir;
sentSessionMat = getPart3SentenceSessionMat();
ivsFileName = [ivectorOutputDir inputSet.gender '_ivectors.mat'];
feaFiles = inputSet.feaFiles;
numFiles = length(feaFiles);        
logLikelihoods = zeros(numFiles, 1);    
digitCount = 10;
covMats = cell(digitCount, 1);
if (~exist(ivsFileName, 'file'))
    fprintf('Extracting i-vectors for %s...\n', inputSet.gender);
    hmmIdMap = gethmmIdMap ();
    [hmms, ~, digitIdx] = getPart3DigitHmms(ubmModels);
    transUbm = []; trans = [];
    if (subspaceHmm)
        transUbm = transformedModels{m};
        trans = transforms{m};
    end
    genderIndepDigStats = cell(2,1);
    digIvectors = cell (digitCount,1);
    digFullId = cell (digitCount,1);

    highestIdx = getHighestTrainingIdx(inputSet.gender);
    ivStatsFileName = [ivectorOutputDir 'stats_' inputSet.gender '.mat'];
    rawStatsFileName = [ivectorOutputDir 'raw_stats_' inputSet.gender '.mat'];
    if (exist(ivStatsFileName, 'file'))
        display ('loading iv stats...');
        load(ivStatsFileName);
    else

        digitStats = cell(11, numFiles);
        stats = cell(numFiles, 1);
        parfor (file = 1 : numFiles, params.nworkers)
            [~, name] = fileparts(feaFiles{file});
            sentidx = str2double(name(end-1:end));
            sessidx = str2double(name(6:7));
            if (sentidx <= 60)
                continue;
            end
            idx = sentSessionMat(sessidx, sentidx);
            fea = htkread(feaFiles{file});
            if (useHmm)
                if (hmms{idx}.nstates > size(fea, 2))
                    warning('Number of frames is lower than number of model states : \nFile path : %s\n', feaFiles{file});
                end
                if (~subspaceHmm)
                    [N, F, logLikelihoods(file)] = compute_hmm_bw_stats(fea, hmms{idx}); 

                else
                    [N, F] = compute_hmm_bw_stats_subspace(fea, trans, ubm, transUbm);
                end
            else
                [N, F] = compute_bw_stats(fea, ubm);
            end
            stats{file} = [N; F];

        end
        %save(rawStatsFileName, 'stats', '-v7.3' );
        for file = 1 : numFiles
            [~, name] = fileparts(feaFiles{file});
            sentidx = str2double(name(end-1:end));
            sessidx = str2double(name(6:7));

            if (sentidx <= 60)
                continue;
            end

            NInd = 1;
            FInd = 1;
            digMixNum = params.hmmStateNum * params.hmmMixtureNum;            
            idx = sentSessionMat(sessidx, sentidx);
            NSize = length(digitIdx{idx})*digMixNum;
            N = stats{file}(1:NSize);
            F = stats{file}(NSize+1:end);
            for digInd=1:length(digitIdx{idx})
                curDig = digitIdx{idx}(digInd);
                digitStats{curDig,file}= [N(NInd:NInd+digMixNum-1);...
                    F(FInd:FInd+(digMixNum*params.featureDim)-1)];
                NInd = NInd + digMixNum;
                FInd = FInd + (digMixNum*params.featureDim);
            end
        end
        %digitStats
        %genderIndepDigStats{1} = digitStats;
        save(ivStatsFileName, 'digitStats', '-v7.3');
    end
    display ('extracting iv from stats...');
    digMixNum = params.hmmStateNum * params.hmmMixtureNum;
    for i=1:digitCount
        temp = digitStats(i,:);
        isFullId = find(~cellfun('isempty',temp));
        temp = temp (~cellfun('isempty',temp));
        ivectors = zeros(params.tvDim, length(temp));
        covMats_m = cell(length(temp), 1);
        curT = T{i};
        hmmId = hmmIdMap(i);  
  %      for file = 1 : length(temp)
        parfor (file = 1 : length(temp), params.nworkers)
            N = temp{file}(1:digMixNum);
            F = temp{file}(digMixNum+1:end);
            if (saveCov)
                [ivectors(:, file), covMats_m{file}]= extract_ivector([N; F], ubmModels{hmmId}, curT, [], saveCov);
            else
                ivectors(:, file) = extract_ivector([N; F], ubmModels{hmmId}, curT, [], saveCov);
            end
        end
        digFullId{i} = isFullId;
        digIvectors{i} = ivectors;
        if (saveCov)
            cov_sum = my_cell_average( covMats_m(1:highestIdx));
            covMats{i} = cov_sum;            
            covsFileName = [ivectorOutputDir inputSet.gender '_ivCovs' int2str(i) '.mat'];
            save(covsFileName, 'cov_sum', '-v7.3');
        end
    end
    save(ivsFileName, 'digIvectors', 'digFullId', 'logLikelihoods'); %, 'logLikelihoods'


    fprintf('Extracting i-vectors for %s finished.\n', inputSet.gender);
else
    fprintf('Loading i-vectors for %s...\n', inputSet.gender);
    load(ivsFileName);
    if (saveCov)
        for i=1:digitCount
          covsFileName = [ivectorOutputDir inputSet.gender '_ivCovs' int2str(i) '.mat'];
          temp = load(covsFileName);
          covMats{i} = temp.cov_sum;
        end
    end
%     ivectors = ivectors(:, sum(ivectors == 0) ~= 200);
    fprintf('Loading i-vectors for %s finished.\n', inputSet.gender);
end

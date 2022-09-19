function T = trainPart3TVS(inputSets, ubmModels, overallModel)
global params;
niter  = 20;
useHmm = params.useHmm;
subspaceHmm = params.subspaceHmm;
if (subspaceHmm && ~useHmm)
    error('For subspace processing useHmm must be true.');
end
prefixes = getPrefixes();
ivectorOutputDir = prefixes.ivectorOutputDir;
if (~exist(ivectorOutputDir, 'dir'))
    mkdir(ivectorOutputDir);
end
sentSessionMat = getPart3SentenceSessionMat();
flag = true;
while (flag)
    flag = false;
     try
        tvFilename = [ivectorOutputDir params.gender '_tv_T10.mat'];
        if (~exist(tvFilename, 'file'))
            hmmIdMap = gethmmIdMap ();
            [hmms, ~, digitIdx] = getPart3DigitHmms(ubmModels);
            %hmms = ubmModels;
            allStats = cell(0, 1);
            genderIndepDigStats = cell(0,1);
            tvStatsFileName = [ivectorOutputDir 'stats_' params.gender '.mat'];
            if (exist(tvStatsFileName, 'file'))
                display ('loading TVS...');
                load(tvStatsFileName);
            else
                for i = 1 : length(inputSets)
                    set = inputSets{i};
                    feaFiles = set.feaFiles;
                    numFiles = length(feaFiles);
                    highestIdx = getHighestTrainingIdx(set.gender);
                    
                    digitStats = cell(11, numFiles);
                    stats = cell(numFiles, 1);
%                     for file = 1 : numFiles
                    parfor (file = 1 : numFiles, params.nworkers)
                        [~, name] = fileparts(feaFiles{file});
                        if (str2double(name(2:4)) > highestIdx || str2double(name(end-2:end)) <= 60) %str2double(name(2:4)) > highestIdx || 
                            continue;
                        end
                        fea = htkread(feaFiles{file});
                        sentidx = str2double(name(end-1:end));
                        sessidx = str2double(name(6:7));
                        idx = sentSessionMat(sessidx, sentidx);
                        if (useHmm)
                            if (~subspaceHmm)
%                                 N = 1; F = [1;2];
                                [N, F] = compute_hmm_bw_stats(fea, hmms{idx}); %#ok<*PFBNS>
                                
%                                [N, F] = convert2newStats(N, F, ubmModels, statesAlignments{idx}, params);
                            else
                                [N, F] = compute_hmm_bw_stats_subspace(feaFiles{file}, trans, ubm, transUbm);
                            end
                        else
                            [N, F] = compute_bw_stats(feaFiles{file}, ubm);
                        end
                        stats{file} = [N; F];
                        
                    end
                    display ('Extracting digit stats ...');
                    for file = 1 : numFiles
                        [~, name] = fileparts(feaFiles{file});
                        if ( str2double(name(2:4)) > highestIdx || str2double(name(end-2:end)) <= 60) %str2double(name(2:4)) > highestIdx ||
                            continue;
                        end
                        sentidx = str2double(name(end-1:end));
                        sessidx = str2double(name(6:7));
                        idx = sentSessionMat(sessidx, sentidx);
                        
                        NInd = 1;
                        FInd = 1;
                        digMixNum = params.hmmStateNum * params.hmmStateNum;
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
                    display (' first gender finished ...');
 %                   stats = stats(~cellfun('isempty', stats));
 %                   allStats = [allStats; stats];
                    genderIndepDigStats{i} = digitStats;
                    
                end
                save(tvStatsFileName, 'genderIndepDigStats', '-v7.3');
            end
            display (' Training TVS ...');
            if (subspaceHmm)
                T = train_tv_space(allStats, transUbm, params.tvDim, niter, params.nworkers, tvFilename);
            else
%                 cnt=1;
%                 for file=1:numFiles
%                     [~, name] = fileparts(feaFiles{file});
%                     if (str2double(name(2:4)) <= highestIdx)
%                         devInds(cnt) = file;
%                         cnt = cnt+1;
%                     end 
%                 end
                
                for i=1:10  
                    
                    tvFilename = [ivectorOutputDir params.gender '_tv_T' int2str(i) '.mat'];
                    if (~exist(tvFilename, 'file'))
%                       temp = digitStats(i,devInds);
%                       temp = temp (~cellfun('isempty',temp));
                      
                      temp = [genderIndepDigStats{1}(i,:) genderIndepDigStats{2}(i,:)];
                      temp = temp (~cellfun('isempty',temp));
                      hmmId = hmmIdMap(i);
                      seed = rng (100 + i);
                      T{i} = train_tv_space( temp, ubmModels{hmmId}, params.tvDim, niter, params.nworkers, tvFilename, seed);
                    end
                end

            end
        else
            display (' loading TVS...');
            for i=1:10
                tvFilename = [ivectorOutputDir params.gender '_tv_T' int2str(i) '.mat'];
                t = load(tvFilename);
                T{i} = t.T;
            end
            display (' loading TVS finished.');
        end
     catch
        flag = true;
     end
end
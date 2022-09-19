function segmentationUsingHmm(inputSets, ubmModels)
global params;
%[hmms, ~, modelsIdx] = getSentenceHmms(ubmModels);
hmmIdMap = gethmmIdMap ();
[hmms, ~, digitIdx] = getPart3DigitHmms(ubmModels);
sentSessionMat = getPart3SentenceSessionMat();
for i = 1 : length(inputSets)

    genders = getGenders();
    outdir = [params.feaDir params.feaType '_' num2str(params.featureDim) '_REM_SIL_CMVN_SEG' filesep genders{1} filesep];
    
    set = inputSets{i};
    feaFiles = set.feaFiles;
    numFiles = length(feaFiles);
    if (~exist(outdir, 'dir')), mkdir(outdir); end
    
    seg = cell(numFiles, 2);
 %    for file = 1 : numFiles
    parfor (file = 1 : numFiles, params.nworkers)
        [~, name] = fileparts(feaFiles{file});
        if (str2double(name(end-2:end)) <= 60) %str2double(name(2:4)) > highestIdx || 
            continue;
        end
        [fea, frate] = htkread(feaFiles{file});
%        feaFiles{file}
        sentidx = str2double(name(end-1:end));
        sessidx = str2double(name(6:7));
        idx = sentSessionMat(sessidx, sentidx);
        if (hmms{idx}.nstates > size(fea, 2))
            warning('Number of frames is lower than number of model states : \nFile path : %s\n', feaFiles{file});
            continue;
        end
        [~, ~, logLikelihood, segmentationInfo] = compute_hmm_bw_stats(fea, hmms{idx});
        feaFiles{file}
        startTime = 0;
        startIdx = 1;
%         fid = fopen([feaFiles{file}(1 : end - 3), 'txt'], 'wt');
%         fprintf('%s\n', feaFiles{file});
%         fprintf(fid, 'LogLikelihood : %.3f\n', logLikelihood);
        ll = cell(length(digitIdx{idx}), 2);
        for j = 1 : length(digitIdx{idx})
            idx2 = digitIdx{idx}(j);
            hmmId = hmmIdMap(idx2);
            hmm = ubmModels{hmmId};
            duration = sum(segmentationInfo(startIdx : startIdx + hmm.nstates - 1));
            startIdx = startIdx + hmm.nstates;
            ll{j, 1} = hmm.name;
            ll{j, 2} = [startTime * 10, (startTime + duration) * 10];
%             fprintf(fid, '%s\t%d\t%d\n', hmm.name, startTime * 10, (startTime + duration) * 10);
            startTime = startTime + duration;
        end        
%         fclose(fid);
        
        if (exist(outdir, 'dir'))
%            [~, spk] = fileparts(file);
            spk = name(1 : 4);
            spkDir = [outdir spk filesep];
            if (~exist(spkDir, 'dir')), mkdir(spkDir); end
            % remove extra sil from end
            if (strcmp(ll{end,1}, 'SIL') && ll{end,2}(2) - ll{end, 2}(1) > 100)
                fea = fea(:, 1 : end - round((ll{end,2}(2) - ll{end, 2}(1)) / 10) + 10);
            end
            % remove extra sil from begining
            if (strcmp(ll{1,1}, 'SIL') && ll{1,2}(2) - ll{1, 2}(1) > 100)
                fea = fea(:, round((ll{1,2}(2) - ll{1, 2}(1)) / 10) - 10 : end);
            end
            htkwrite([spkDir name '.fea'], fea, frate, 838); % 838 for MFCC_E_D_A
 %           [spkDir name '.fea']
        end
        seg(file, :) = {logLikelihood, ll};
    end
    save([params.mainOutputDir set.gender '_seg.mat'], 'seg');
end
function [ubmModels, overallModel] = trainUbmModels()
global params;
prefixes = getPrefixes();
modelsOutputDir = prefixes.modelsOutputDir;
if (~exist(modelsOutputDir, 'dir'))
    mkdir(modelsOutputDir);
end
if (params.useHmm)
    ubmFile = [modelsOutputDir params.gender '_UBM.mmf'];
    if (~exist(ubmFile, 'file'))
        trainHmmUbmUsingHtk();
    end
    ubmModels = read_htk_hmm(ubmFile);
    for i = 1 : length(ubmModels)
        sigma = [];
        for ii = 1 : ubmModels{i}.nstates
            sigma = [sigma, ubmModels{i}.gmms(ii).covars]; %#ok<AGROW>
        end
        ubmModels{i}.sigma = sigma;
        ubmModels{i}.covar_type = 'diag';
    end
    sigma = [];
    for i = 1 : length(ubmModels)
        if (i == params.silIndex), continue; end
        for ii = 1 : ubmModels{i}.nstates
            sigma = [sigma, ubmModels{i}.gmms(ii).covars]; %#ok<AGROW>
        end
    end
    overallModel.sigma = sigma;
    overallModel.covar_type = 'diag';
    return;
end
% final_niter = 10;
% ds_factor = 1;
% ubmModels = cell(params.nMonth, 1);
% ubmFileNames = cell(params.nMonth, 1);
% for i = 1 : params.nMonth
%     ubmFileNames{i} = [modelsOutputDir 'ubm_' num2str(i) '.mat'];
%     if (~exist(ubmFileNames{i}, 'file'))
%         ubmModels{i} = gmm_em(inputSet.features{i}, params.nmix, final_niter, ds_factor, params.nworkers, ubmFileNames{i});
%     else
%         ubm = load(ubmFileNames{i});
%         ubmModels{i} = ubm.gmm;
%     end
% end
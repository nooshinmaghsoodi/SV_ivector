function prefixes = getPrefixes()
global params;
if (params.useHmm)
    model = ['_HMM-' num2str(params.hmmStateNum) '-' num2str(params.hmmMixtureNum)];
else
    model = ['_GMM-' num2str(params.nmix)];
end
partId = '';
if (params.isPart3), partId = '_Part3'; end
prefixes.modelsOutputDir = [params.mainOutputDir params.feaType '_' num2str(params.featureDim) partId model filesep];
prefixes.ivectorOutputDir = [prefixes.modelsOutputDir num2str(params.tvDim) filesep];
paramPrefix = '';
% if (params.usePca)
%     paramPrefix = [paramPrefix 'Pca_' num2str(params.numOfPrincomp) '_'];
% end
% if (params.useWccn)
%     paramPrefix = [paramPrefix 'Wccn_'];
% end
% if (params.useLda)
%     paramPrefix = [paramPrefix 'Lda_' num2str(params.ldaDim) '_'];
% end
% if (params.whiteningData)
%     paramPrefix = [paramPrefix 'Whiten_'];
% end
% if (params.normalizeLength)
%     paramPrefix = [paramPrefix 'NormLen_'];
% end
% if (params.usePlda)
%     paramPrefix = [paramPrefix 'Plda_' num2str(params.pldaDim) '_'];
% end
% if (params.useSvmScoring)
%     paramPrefix = [paramPrefix 'SVM_'];
% end
prefixes.paramPrefix = paramPrefix(1 : end - 1);
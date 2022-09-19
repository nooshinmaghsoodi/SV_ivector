function setParams
global params;
params = [];
params.saveCov = true;
params.nworkers = min(12, feature('NumCores'));
params.gender = 'both';
params.useHmm = true;
params.subspaceHmm = false;
params.configFile = 'mfcc60.cfg';
params.printOpt = true;
params.feaType = 'BN';
params.featureDim = 80;
params.hmmStateNum = 8;
params.hmmMixtureNum = 8;
params.subsetsSize = struct('male', [50, 50, 57], 'female', [47, 47, 49]);
params.useDevSetForTraining = false;
params.useOnlyDevSetForTraining = true;
params.tvDim = 300;
params.silIndex = 11;
params.cmvn = true;
params.featureExtracted = true;
params.featureTransformed = true;
params.use_within = false;
params.fusion = true;
params.fusionDetail = 'feature_MFCC-USER'; %feature_MFCC-PLP or method_PLP or method_MFCC all_PLP

params.rsrHome = '/home/nmaghsoodi.ce.sharif/tdsv_rsr/RSR2015/';
params.feaDir = '/home/nmaghsoodi.ce.sharif/tdsv_rsr/Features/';
params.mainOutputDir = '/home/nmaghsoodi.ce.sharif/tdsv_rsr/PartIII/';

function setParams
global params;
params = [];
params.nworkers = min(12, feature('NumCores'));
params.gender = 'both';
params.useHmm = true;
params.subspaceHmm = false;
params.isPart3 = false;
params.configFile = 'mfcc39.cfg';
params.printOpt = true;
params.feaType = 'MFCC_E_D_A';
params.featureDim = 39;
params.hmmStateNum = 3;
params.hmmMixtureNum = 8;
params.subsetsSize = struct('male', [50, 50, 57], 'female', [47, 47, 49]);
params.useDevSetForTraining = false;
params.tvDim = 400;
params.silIndex = 40;
params.rsrHome = '/mnt/matylda4/qcumani/TOSREW/DATA/RSR2015/';
params.feaDir = '/mnt/matylda6/zeinali/RSR_Experiments/MFCC12_TRIM_CMVN_16k/Features/';
params.mainOutputDir = '/mnt/matylda6/zeinali/Matlab/PartI/';
function extractAllFeatures()
addpath('HMM');
addpath('Utilities');
addpath('bin');
setParams();

fileLists = getFileLists();
extractFeaturesUsingHCopy(fileLists);

function fileLists = getFileLists()
global params;
genders = getGenders();
sphFiles = cell(0, 1);
feaFiles = cell(0, 1);
for g = 1 : length(genders)
    outDir = [params.feaDir params.feaType '_' num2str(params.featureDim) filesep];
    if (~exist(outDir, 'dir')), mkdir(outDir); end
    inputDir = params.wavHome;
    files = dir([inputDir '*.sph']);
    for j = 1 : length(files)
        feaPath = [outDir files(j).name(1 : end - 3) 'fea'];
        if (exist(feaPath, 'file')), continue; end
        feaFiles{end + 1, 1} = feaPath; %#ok<*AGROW>
        sphFiles{end + 1, 1} = [inputDir files(j).name];
        
    end
end
fileLists = cell(2, 1);
fileLists{1} = sphFiles;
fileLists{2} = feaFiles;


function extractFeaturesUsingHCopy(fileLists)
global params;
if (~exist(params.mainOutputDir, 'dir')), mkdir(params.mainOutputDir); end
scpFiles = createListFileForHCopy(params, [params.mainOutputDir 'temp' filesep], fileLists);
dirPath = [params.mainOutputDir 'temp' filesep];
for n = 1 : params.nworkers
  scpFiles{n, 1} = [dirPath 'sph2fea_' num2str(n) '.scp'];
end

configFile = [filesep pwd filesep 'Resources' filesep params.configFile];
parfor i = 1 : length(scpFiles)
    cmd = sprintf('bin%cHCopy -C "%s" -S "%s"', configFile, scpFiles{i})
    
    [status, cmdOut] = system(cmd);
    if (status ~= 0)
        error(cmdOut);
    end
end

function lstFiles = createListFileForHCopy(params, dirPath, fileLists)
if (~exist(dirPath, 'dir')), mkdir(dirPath); end
sphFiles = fileLists{1};
feaFiles = fileLists{2};
partSize = ceil(length(sphFiles) / params.nworkers);
lstFiles = cell(0, 1);
for n = 1 : params.nworkers
    if ((n - 1) * partSize + 1 > min(length(sphFiles), n * partSize))
        break;
    end
    lstFiles{n, 1} = [dirPath 'sph2fea_' num2str(n) '.scp'];
    filePath = lstFiles{n};
    fid = fopen(filePath, 'wt');
    for i = (n - 1) * partSize + 1 : min(length(sphFiles), n * partSize)
        fprintf(fid, '"%s"\t"%s"\n', sphFiles{i}, feaFiles{i});
    end
    fclose(fid);
end

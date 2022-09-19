function inputSet = makeSpeakerModelUsingMap(inputSet)
global params;
prefixes = getPrefixes();
modelsOutputDir = [prefixes.modelsOutputDir 'HMMs' filesep 'Speakers' filesep];
ubmPath = [prefixes.modelsOutputDir 'HMMs' filesep 'UBM.mmf'];
if (~exist(modelsOutputDir, 'dir')), mkdir(modelsOutputDir); end
if (~exist([modelsOutputDir 'Temp'], 'dir')), mkdir([modelsOutputDir 'Temp']); end
modelsCount = length(inputSet.speakersId);
modelIndexMap = containers.Map('KeyType', 'char', 'ValueType', 'int32');
for model = 1 : modelsCount
    modelIndexMap(inputSet.speakersId{model}) = model;
end
nMonth = params.nMonth;
models = cell(nMonth, 1);
models(1 : end) = {cell(modelsCount, 1)};
modelsPath = cell(modelsCount, 1);
feaFilesPath = inputSet.feaFilesPath;
labels = inputSet.labels;
speakersId = inputSet.speakersId;
parfor model = 1 : modelsCount
    feaFiles = cell(nMonth, 1);
    for m = 1 : nMonth
        feaFiles{m} = feaFilesPath{m}(labels{m} == model); %#ok<*PFBNS>
    end
    modelsPath{model} = trainOneModel(speakersId{model}, feaFiles, modelsOutputDir, ubmPath);
end
for model = 1 : modelsCount
    spkModels = read_htk_hmm(modelsPath{model});
    for m = 1 : nMonth
        models{m}{model, 1} = spkModels{m};
    end
end
inputSet.modelIndexMap = modelIndexMap;
inputSet.models = models;
if (exist([modelsOutputDir 'Temp'], 'dir')), rmdir([modelsOutputDir 'Temp'], 's'); end

function hmmPath = trainOneModel(speakerId, feaFiles, modelsOutputDir, ubmPath)
hmmPath = [modelsOutputDir speakerId '.hmm'];
if (exist(hmmPath, 'file'))
    return;
end
tempDir = [modelsOutputDir 'Temp' filesep];
mlfFile = [tempDir speakerId '.mlf'];
scpFile = [tempDir speakerId '.scp'];
mlf = fopen(mlfFile, 'wt');
scp = fopen(scpFile, 'wt');
fprintf(mlf, '#!MLF!#\n');
for m = 1 : length(feaFiles)
    for i = 1 : length(feaFiles{m})
        fprintf(scp, '"%s"\n', feaFiles{m}{i});
        fprintf(mlf, '"%slab"\nM%d\n.\n', strrep(feaFiles{m}{i}(1 : end - 3), filesep, '/'), m);
    end
end
fclose(mlf);
fclose(scp);
hmmPath = [modelsOutputDir speakerId '.hmm'];
copyfile(ubmPath, hmmPath);
mnlFile = [tempDir speakerId '.mnl'];
fid = fopen(mnlFile, 'w');
for i = 1 : length(feaFiles)
    fprintf(fid, 'M%d\n', i);
end
fclose(fid);
configFile = [pwd filesep 'Resources' filesep 'config2'];
itterationNum = 5;
for i = 1 : itterationNum
	cmd = sprintf('HERest -C "%s" -u mp -I "%s" -S "%s" -H "%s" "%s"', configFile, mlfFile, scpFile, hmmPath, mnlFile);
	[status, result] = dos(cmd);
    if status ~= 0
        warning(result);
        return;
    end
end

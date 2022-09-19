function trainHmmUbmUsingHtk()
prefixes = getPrefixes();
outputDir = prefixes.modelsOutputDir;
if (~exist(outputDir, 'dir')), mkdir(outputDir); end
display('Start UBM training...');

[mlfFile, scpFile] = genLabelFiles([outputDir 'temp' filesep]);

genTemplateAndDoHCompV(outputDir, scpFile);

createUbmFromHCompV(outputDir);

doRestimation(outputDir, mlfFile, scpFile);

display('Finished UBM training...');

function [mlfFile, scpFile] = genLabelFiles(outputDir)
if (~exist(outputDir, 'dir')), mkdir(outputDir); end
feaFiles = getFeatureFiles();
transMap = getPart3FilesTranscribtions();
mlfFile = [outputDir 'trainFea.mlf'];
scpFile = [outputDir 'trainFea.scp'];
mlf = fopen(mlfFile, 'w');
scp = fopen(scpFile, 'w');
fprintf(mlf, '#!MLF!#\n');
for i = 1 : length(feaFiles)
    [~, name] = fileparts(feaFiles{i});
    fprintf(scp, '"%s"\n', feaFiles{i});
    fprintf(mlf, '"%slab"\nSIL\n', strrep(feaFiles{i}(1 : end - 3), filesep, '/'));
    trans = strsplit(transMap([name(end - 5 : end-4) name(end - 2 : end)]));
    for j = 1 : length(trans)
        fprintf(mlf, '%s\n', trans{j});
    end
    fprintf(mlf, 'SIL\n.\n');
end
fclose(mlf);
fclose(scp);

function feaFiles = getFeatureFiles()
global params;
genders = getGenders();
feaFiles = cell(0, 1);
prefix = [num2str(params.featureDim) '_REM_SIL_CMVN'];%
for g = 1 : length(genders)
    
    feaDir = params.feaDir ;
    speakers = dir(feaDir); speakers = speakers(3 : end);
    highestIdx = getHighestTrainingIdx(genders{g});
    for i = 1 : length(speakers)
        if (str2double(speakers(i).name(2:end)) > highestIdx), continue; end
        spkFeaDir = [feaDir speakers(i).name filesep];
        files = dir([spkFeaDir '*.fea']);
        for j = 1 : length(files)
            if (str2double(files(j).name(9:11)) > 60)
                feaPath = [spkFeaDir files(j).name];
                feaFiles{end + 1, 1} = feaPath; %#ok<*AGROW>
            end
        end
    end
end

function genTemplateAndDoHCompV(outputDir, scpFile)
global params;
if (params.printOpt), fprintf('Generate HMM template file template.hmm\n'); end
if (~exist([outputDir 'temp'], 'dir')), mkdir([outputDir 'temp']); end
templateFile = [outputDir 'temp' filesep 'template.hmm'];
mixtureNum = 1;
genTemplateHmmFile(params.feaType, params.featureDim, params.hmmStateNum, templateFile, mixtureNum);

if (params.printOpt), fprintf('Populate template.hmm to generate hcompv.hmm\n'); end
cmd = sprintf('bin%cHCompV -f 0.01 -m -o hcompv.hmm -S "%s" -M "%s" "%s"', filesep, scpFile, [outputDir 'temp'], templateFile);
[status, result] = system(cmd);
if (status ~= 0)
    error(result);
end

function createUbmFromHCompV(outputDir)
global params;
if (params.printOpt), fprintf('Duplidate hcompv.hmm to generate UBM.hmm\n'); end
hmmFile = [outputDir 'temp' filesep 'hcompv.hmm'];
fid = fopen(hmmFile, 'r');
contents = fread(fid, inf, 'char');
contents = char(contents');
fclose(fid);
fid = fopen([outputDir 'temp' filesep 'vFloors'], 'r');
vFloors = fread(fid, inf, 'char');
vFloors = char(vFloors');
fclose(fid);
fid = fopen(['Resources' filesep 'models.mnl'], 'r');
models = textscan(fid, '%s'); models = models{1};
fclose(fid);
parts = strsplit(contents, '~h "hcompv.hmm"');
ubmFile = [outputDir params.gender '_UBM.mmf'];
fid = fopen(ubmFile, 'w');
fprintf(fid, '%s%s', parts{1}, vFloors);
for i = 1 : length(models)
	fprintf(fid, '~h "%s"%s', models{i}, parts{2});
end
fclose(fid);

function doRestimation(outputDir, mlfFile, scpFile)
global params;
if (params.printOpt), fprintf('Restimate models via EM\n'); end
ubmFile = [outputDir params.gender '_UBM.mmf'];
scurModelList = sprintf('%s%sResources%smodels.mnl', pwd, filesep, filesep);
for i = 1 : params.hmmMixtureNum + 1
    cmd = sprintf('bin%cHERest -w 0.1 -I "%s" -S "%s" -H "%s" "%s"', ...
        filesep, mlfFile, scpFile, ubmFile, scurModelList)
    for j = 1 : 5
        [status, result] = system(cmd);
        if (status ~= 0)
            error(result);        
        end
    end
    if (i < params.hmmMixtureNum)
        hhedFile = [outputDir 'temp' filesep 'mxup.scp'];
        fid = fopen(hhedFile, 'w');
        fprintf(fid, 'MU %d {*.state[2-%d].mix}\n', i + 1, params.hmmStateNum + 1); fclose(fid);
        cmd = sprintf('bin%cHHEd -H "%s" "%s" "%s"', filesep, ubmFile, hhedFile, scurModelList);
        [status, result] = system(cmd);
        if (status ~= 0)
            error(result);        
        end
        if (params.printOpt), fprintf('Mixture up to %d finished\n', i + 1); end
    end
end
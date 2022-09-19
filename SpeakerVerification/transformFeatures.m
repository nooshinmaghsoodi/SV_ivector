function transformFeatures(sets, inputDir, feaType, feaDim)
inputDir = [inputDir  feaType '_' int2str(feaDim)];
outputDir = [inputDir  '_REM_SIL_CMVN'];
if (inputDir(end) ~= filesep), inputDir(end + 1) = filesep; end
if (outputDir(end) ~= filesep), outputDir(end + 1) = filesep; end

for i = 1 : length(sets)
    set = sets{i};
    inDir = [inputDir set.gender filesep];
    outDir = [outputDir set.gender filesep];
    if (~exist(outDir, 'dir')), mkdir(outDir); end
    speakers = dir(inDir); 
    speakers = speakers(3 : end);
    for j = 1 : length(speakers)
        inSpkDir = [inDir speakers(j).name filesep];
        outSpkDir = [outDir speakers(j).name filesep];
        if (~exist(outSpkDir, 'dir')), mkdir(outSpkDir); end
        spkFiles = dir([inSpkDir '*.fea']);
        for k = 1 : length(spkFiles)
            outFile = [outSpkDir spkFiles(k).name];
               [fea, frate, fkind] = htkread([inSpkDir spkFiles(k).name]);
               fea = wcmvn(fea, 151, 1);
               if (strcmp(feaType, 'MFCC_E_D_A'))
                  htkwrite(outFile, fea, frate, 838); % 838 for MFCC_E_D_A
               else
                   
                   htkwrite(outFile, fea, frate, fkind);
               end
        end
    end
end
function [speakersMatrix, speakersId, vectorsLabel] = createSpeakersMatrix(modelVectors, modelVectorId2IndexMap)
global params;
filePath = [params.inputDataDir 'target_speaker_models.csv'];
fid = fopen(filePath);
spks = textscan(fid, '%s', inf, 'delimiter', '\n', 'HeaderLines', 1);
spks = spks{1};
fclose(fid);
matPath = [params.outputDir 'Data\'];
if (~exist(matPath, 'dir')), mkdir(matPath); end
[~, name] = fileparts(filePath);
matPath = [matPath name '.mat'];
if (exist(matPath, 'file'))
    load(matPath);
    return;
end
speakersMatrix = zeros(size(modelVectors));
speakersId = cell(length(spks), 1);
vectorsLabel = zeros(size(speakersMatrix, 1), 1);
eachSpkVectorCount = 5;
for i = 1 : length(spks)
    parts = strsplit(spks{i}, ',');
    speakersId{i} = parts{1};
    filesId = strsplit(parts{2}, ' ');
    for j = 1 : length(filesId)
        idx = (i - 1) * eachSpkVectorCount + j;
        if (modelVectorId2IndexMap.isKey(filesId{j}))
            speakersMatrix(idx, :) = modelVectors(modelVectorId2IndexMap(filesId{j}), :);
            vectorsLabel(idx, 1) = i;
        else
            error('Error : Vector key not found%s\n', filesId{j});
        end
    end
end
save(matPath, 'speakersMatrix', 'speakersId', 'vectorsLabel');
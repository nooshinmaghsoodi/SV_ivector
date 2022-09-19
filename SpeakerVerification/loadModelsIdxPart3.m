function [modelsIndexes, modelsId2Index] = loadModelsIdxPart3(inputSet, ndx)
global params;
parts = { 'eval'};
if strcmp(ndx , '3seq10_10seq5')
    trainSize = 13;
else
    trainSize = 3;
end
fileName = [ndx '_' parts{1} '_' inputSet.gender(1) '.trn'];
filePath = [params.rsrHome 'key' filesep 'part3' filesep 'trn' filesep fileName];
matPath = [params.mainOutputDir ndx '_' inputSet.gender(1) '.trn.mat'];
if (exist(matPath, 'file'))
    load(matPath);
    return;
end

fid = fopen(filePath, 'rt');
lines = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
lines = lines{1};
modelsIndexes = zeros(length(lines), trainSize+2, 'int32');% two additional columns for speaker ID and session number
modelsId2Index = zeros( length(inputSet.speakersId), 7);

format = [inputSet.gender(1) '%d_%d'];
for lineNum=1:length(lines)
    curline = lines(lineNum);
    lineParts = strsplit(curline{1}, {',', ' '});
    mids = textscan(lineParts{1}, format);
    modelsIndexes(lineNum, 1) = mids{1};
    modelsIndexes(lineNum, 2) = mids{2};
    for i = 2 : length(lineParts)
        fName = lineParts{i}(end - 13 : end - 4);
        ids = textscan(fName, '%d_%d_%d');
        idx = inputSet.id2index(ids{2}, ids{3}, ids{1});
        modelsIndexes(lineNum, i+1) = idx;
    end
    modelsId2Index (mids{1}, mids{2}) = lineNum;
end

%end
%modelsIndexes = modelsIndexes(1 : cnt - 1, :);
save(matPath, 'modelsIndexes', 'modelsId2Index');
function set = loadGenderSet(gender, transformed)

global params;

dirPath = params.feaDir;
set.gender = gender;
files = dir([dirPath gender(1) '*.fea']);

speakers = dir(dirPath); 
speakers = speakers(3 : end);
numSpeakers = length(speakers);
speakersId = cell(numSpeakers, 1);
id2index = zeros(9, 73, numSpeakers);
feaFiles = cell(0, 1);
spkLabels = zeros(0, 1);
sentenceId = zeros(0, 1);
sessionId = zeros(0, 1);
feaIndex = 0;
for i = 1 : numSpeakers
    speakersId{i} = speakers(i).name;
    files = dir([dirPath gender(1) '*.fea']);
    cnt = 0;
    spkId = str2double(speakersId{i}(2 : end));
    for k = 1 : length(files)
        feaPath = [dirPath files(k).name];
        senId = str2double(files(k).name(9 : 11));
        if (senId <= 60)
            continue;
        end
        feaIndex = feaIndex + 1;
        sessId = str2double(files(k).name(6 : 7));
        feaFiles{feaIndex, 1} = feaPath;
        sentenceId(feaIndex, 1) = senId;
        sessionId(feaIndex, 1) = sessId;
        id2index(sessId, senId, spkId) = feaIndex;
        cnt = cnt + 1;
    end
    spkLabels = [spkLabels; spkId * ones(cnt, 1)]; %#ok<*AGROW>
end
set.speakersId = speakersId;
set.feaFiles = feaFiles;
set.spkLabels = spkLabels;
set.sentenceId = sentenceId;
set.sessionId = sessionId;
set.id2index = id2index;
function transMap = getFilesTranscribtions()
fid = fopen(['Resources' filesep 'sentences.txt'], 'rt');
sents = textscan(fid, '%s', 'delimiter', '\n'); sents = sents{1};
fclose(fid);
transMap = containers.Map;
for i = 1 : length(sents)
    parts = strsplit(sents{i}, '\t');
    transMap(parts{1}) = parts{3};
end
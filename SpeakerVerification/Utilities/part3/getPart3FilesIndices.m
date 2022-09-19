function transMap = getPart3FilesIndices()
fid = fopen(['Resources' filesep 'p3prompts.lst'], 'rt');
sents = textscan(fid, '%s', 'delimiter', '\n'); 
sents = sents{1};
fclose(fid);
transMap = containers.Map;
for i = 1 : length(sents)
    parts = strsplit(sents{i}, ',');
    transMap(int2str(i)) = parts{3};%[parts{1} parts{2}]
end
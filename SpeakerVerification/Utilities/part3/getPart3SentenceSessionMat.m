function transMat = getPart3SentenceSessionMat()
fid = fopen(['Resources' filesep 'p3prompts.lst'], 'rt');
sents = textscan(fid, '%s', 'delimiter', '\n');
sents = sents{1};
fclose(fid);
transMat = zeros(9, 13);
for i = 1 : length(sents)
    parts = strsplit(sents{i}, ',');
    transMat(str2double(parts{1}),str2double(parts{2})) = i;%[parts{1} parts{2}] int2str(i)
end
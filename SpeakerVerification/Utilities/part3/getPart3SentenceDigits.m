function transMap = getPart3SentenceDigits()
fid = fopen(['Resources' filesep 'p3prompts.lst'], 'rt');
sents = textscan(fid, '%s', 'delimiter', '\n');
digMap = getDigitMap();
sents = sents{1};
fclose(fid);
transMap = containers.Map;
for i = 1 : length(sents)
    parts = strsplit(sents{i}, ',');
    digs = strsplit (parts{3}, ' ');
    temp =0;
    for j=1:length(digs)
        temp = [temp digMap(digs{j})];
    end
    transMap([parts{1} parts{2}]) = temp;%[parts{1} parts{2}] int2str(i)
end
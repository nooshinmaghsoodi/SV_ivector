function [trials, trialContent] = loadTrialsPart3(inputSet, ndxFile)
global params;
gender = inputSet.gender(1);
transMap = getPart3Sentence2IdMap();
matPath = [params.mainOutputDir ndxFile '_' gender '.ndx.mat'];
contentmatPath = [params.mainOutputDir ndxFile '_' gender '.ndxcontent.mat'];
if (exist(matPath, 'file'))
    load(matPath);
    load(contentmatPath);
    return;
end
filePath = [params.rsrHome 'key' filesep 'part3' filesep 'ndx' filesep ndxFile '_' gender '.ndx'];
fid = fopen(filePath, 'rt');
lines = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
lines = lines{1};
trials = zeros(length(lines), 4, 'int32');

cnt = 1;
% nread = 50000;
% lines = fread(fid, inf, 'char');
% line = char(lines((cnt - 1) * 37 + 1 : cnt * 37 - 1));
gender = [gender '%d_%d'];
for lineNum = 1:length(lines)
%     line = char(lines((cnt - 1) * 37 + 1 : cnt * 37 - 1));
    line = lines(lineNum);
    line = line{1};
    %parts = strsplit (line, ',');
    parts = {line(1:9), line(11:17), line(19:38), line(40), line(42) ,line(44), line(46)};
    i = 4;
    while (parts{i} == 'N'), i = i + 1; end
    fName = parts{3}(7 : 16);
    ids = textscan(fName, '%d_%d_%d');
    mids = textscan(parts{2}, gender);
    idx = inputSet.id2index(ids{2}, ids{3}, ids{1});
    trials(cnt, :) = [mids{1}, mids{2}, idx, i - 3];
    trialContent{cnt} = transMap(parts{1});
    cnt = cnt + 1;
end
trials = trials(1 : cnt - 1, :);
save(matPath, 'trials');
save(contentmatPath, 'trialContent');
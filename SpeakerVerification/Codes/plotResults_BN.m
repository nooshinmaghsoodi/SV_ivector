function plotResults_BN()
addpath('Utilities');
outDir = '/homes/kazi/zeinali/Documents/2016-Odyssey/Speaker Verification/Figures/';
% Test
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/red_docs_both_False_HMM_936_RedDocs_400_imposter_wrong/'},...
%                 };


% Feature comparison
% score_dirs = {
%                {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_1011Post/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 };

% Feature fusion
% score_dirs = {
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC12_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_PLP12_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_PLP19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 };

% Score fusion
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_PLP12_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_snorm_wccnf400/'},...
%                 };

%female
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 };

% Male
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
%                 '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 };

score_dirs = {
                {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_1011Post/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_PLP12_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
                '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
                '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
                '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
                '/mnt/matylda6/zeinali/RSR_Experiments/PLP12_TRIM_CMVN_USEPOWER_No/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/',...
                '/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
                };

% HMM, GMM
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_GMM_1024_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_GMM_1011_Post_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_GMM_1024_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_GMM_1011_Post_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_GMM_1024_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_GMM_1011_Post_400_patrick_snorm_wccnf400/'},...
%                 };
% score_dirs = {
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_GMM_1024_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/MFCC19_TRIM_CMVN_16k/ProcessedFiles/Scores/both_False_GMM_1011_Post_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 {'/mnt/matylda6/zeinali/RSR_Experiments/Switchboard_BN80_8kPost_MFCC19_16k/ProcessedFiles/Scores/both_False_HMM_936_400_patrick_snorm_wccnf400/'},...
%                 };

% Fea comparison
% legends = {...
%     'PLP39',...
%     'MFCC60',...
%     'Bottleneck80(1)',...
%     'Bottleneck80(2)',...
%     };

% fea fusion
% legends = {...
%     'MFCC39, Bottleneck80(2)',...
%     'MFCC60, Bottleneck80(2)',...
%     'PLP39, Bottleneck80(2)',...
%     'PLP60, Bottleneck80(2)',...
%     };

% Score fusion
% legends = {...
%     'MFCC60 + PLP39',...
%     'MFCC60 + Bottleneck80(2)',...
%     'PLP39 + Bottleneck80(2)',...
%     'MFCC60 + (PLP39, Bottleneck80(2))',...
%     'MFCC60 + PLP39 + Bottleneck80(2)',...
%     };

% HMM, GMM, DNN
legends = {...
    'MFCC39, GMM',...
    'MFCC39, HMM',...
    'MFCC39, DNN',...
    'Bottleneck80(2), GMM',...
    'Bottleneck80(2), HMM',...
    'Bottleneck80(2), DNN',...
    'MFCC39, Bottleneck80(2), GMM',...
    'MFCC39, Bottleneck80(2), HMM',...
    'MFCC39, Bottleneck80(2), DNN',...
    };

% legends = {...
%     'MFCC, GMM',...
%     'MFCC, HMM',...
%     'MFCC, DNN',...
%     'BN, HMM',...
%     'MFCC + BN, HMM',...
%     };

% Female
% legends = {...
%     'MFCC',...
%     'PLP',...
%     'BN',...
%     'MFCC + BN',...
%     'MFCC, PLP (Fusion)',...
%     'MFCC, BN (Fusion)',...
%     'MFCC, PLP, BN, (Fusion)',...
%     };
% Male
% legends = {...
%     'BN',...
%     'PLP',...
%     'MFCC',...
%     'MFCC + BN',...
%     'MFCC, PLP (Fusion)',...
%     'MFCC, BN (Fusion)',...
%     'MFCC, PLP, BN, (Fusion)',...
%     };

plot_all(score_dirs, legends, 'female')
figuresize(22, 22, 'centimeters');

outFile = 'GMM_HMM_DNN_Female.pdf';
print('-dpdf', [outDir outFile]);

function plot_all(score_dirs, legends, gender)
colors = {  
            [0 0 1]	'b'	'blue'
            [1 0 0]	'r'	'red'
            [0 1 0]	'g'	'green'
            [1 0 1]	'm'	'magenta'
            [0 1 1]	'c'	'cyan'
            [0 0 0]	'k'	'black'
            [0 0 1]	'b'	'blue'
            [1 0 1]	'm'	'magenta'
            [1 0 0]	'r'	'red'
            [0 1 0]	'g'	'green'
            [0 1 1]	'c'	'cyan'
            [0 0 0]	'k'	'black'
        };
types = {'-', '-.', '-', '--', '--', '-.', '--', '-.', '-', '-', '--', '-.'};
figure;
hold on;
dcf_points = {};
for i = 1 : length(score_dirs)
    dir_path = score_dirs{i};
    true_scores = 0;
    false_scores = 0;
    for j = 1 : length(dir_path)
        true_scores = true_scores + load([dir_path{j} gender '_true.txt']) / length(dir_path);
        false_scores = false_scores + load([dir_path{j} gender '_false.txt']) / length(dir_path);
    end
    [eer, minDcf08, dcf10, ~, ~, dcf_points{i}] = my_eer([true_scores; false_scores], [ones(length(true_scores), 1);...
        zeros(length(false_scores), 1)], true, colors{i, 1}, types{i});
    fprintf('EER : %.2f, NDCF08 : %.4f, NDCF10 : %.4f\n', eer, minDcf08 / 10, dcf10 * 10);
end
h = legend(legends);
set(h, 'FontSize', 18)
set(h, 'FontName', 'Times New Roman')
h = xlabel ('False Positive Rate (FPR) [%]');
set(h, 'FontSize', 18)
set(h, 'FontName', 'Times New Roman')
h = ylabel ('False Negative Rate (FNR) [%]');
set(h, 'FontSize', 18)
set(h, 'FontName', 'Times New Roman')
for i = 1 : length(score_dirs)
    s1 = scatter(dcf_points{i}(1, 1), dcf_points{i}(1, 2), 120, 's', 'filled', 'MarkerFaceColor', colors{i, 1});
    s1.MarkerEdgeColor = 'k';
    s1.LineWidth = 0.6;
    s1 = scatter(dcf_points{i}(2, 1), dcf_points{i}(2, 2), 150, 'p', 'filled', 'MarkerFaceColor', colors{i, 1});
    s1.MarkerEdgeColor = 'k';
    s1.LineWidth = 0.6;
end

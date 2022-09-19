function [eer, dcf08, dcf10, dcf_ivector_challenge, dcf_ivector_challenge_threshold, dcf_points] = my_eer(scores, labels, showfig, color, lineType)

if iscell(labels),

    labs = zeros(length(labels), 1);

    labs(ismember(labels, 'target')) = 1;

    labels = labs; clear labs;

end



[~,I] = sort(scores);

x = labels(I);



FN = cumsum( x == 1 ) / (sum( x == 1 ) + eps);

TN = cumsum( x == 0 ) / (sum( x == 0 ) + eps);

FP = 1 - TN;

TP = 1 - FN;



FNR = FN ./ ( TP + FN + eps );

FPR = FP ./ ( TN + FP + eps );

difs = FNR - FPR;

idx1 = find(difs< 0, 1, 'last');

idx2 = find(difs>= 0, 1 );

x = [FNR(idx1); FPR(idx1)];

y = [FNR(idx2); FPR(idx2)];

a = ( x(1) - x(2) ) / ( y(2) - x(2) - y(1) + x(1) );

eer = 100 * ( x(1) + a * ( y(1) - x(1) ) );

dcf_points = zeros(2);

if ( nargout > 1 ),

    Cmiss = 10; Cfa = 1; P_tgt = 0.01; % SRE-2008 performance parameters

    Cdet  = Cmiss * FNR * P_tgt + Cfa * FPR * ( 1 - P_tgt);

%     Cdefault = min(Cmiss * P_tgt, Cfa * ( 1 - P_tgt));

    [dcf08, idx] = min(Cdet);

    dcf_points(1, :) = [FPR(idx), FNR(idx)];

    dcf08 = 100 * dcf08; % note this is not percent

    thre08 = scores(I(idx));

end

if (nargout > 2)

    Cmiss = 1; Cfa = 1; P_tgt = 0.001; % SRE-2010 performance parameters

    Cdet  = Cmiss * FNR * P_tgt + Cfa * FPR * ( 1 - P_tgt);

%     Cdefault = min(Cmiss * P_tgt, Cfa * ( 1 - P_tgt));

    [dcf10, idx] = min(Cdet);

    dcf_points(2, :) = [FPR(idx), FNR(idx)];

    dcf10 = 100 * dcf10; % note this is not percent

    thre10 = scores(I(idx));

end

%  DCF(thresh=t) = (# misses(thresh=t) / # target trials) + (100 � # false alarms(thresh=t) / # non-target trials) 

if (nargout > 3)

    Cmiss = 1; Cfa = 100;	% NIST IVectirChallenge performance parameters

    Cdet  = Cmiss * FNR + Cfa * FPR;

    [dcf_ivector_challenge, idx] = min(Cdet);

    dcf_ivector_challenge_threshold = scores(I(idx));

end



dcf_points = my_icdf(dcf_points);

if showfig

%     figure

    plot_det(FPR, FNR, color, lineType)

end



function plot_det(FPR, FNR, color, lineType)

% plots the detection error tradeoff (DET) curve

fnr = my_icdf(FNR);

fpr = my_icdf(FPR);

h = plot(fpr, fnr, lineType, 'LineWidth', 2.5);

set(h, 'Color', color);



xtick = [ 0.00002, 0.00005, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5];

xticklabel = { '0.002', '0.005', '0.01', '0.02', '0.05', '0.1', '0.2', '0.5', '1', '2', '5', '10', '20', '50'};

% xticklabel = num2str(xtick * 100, '%g\n');

% xticklabel = textscan(xticklabel, '%s'); xticklabel = xticklabel{1};

set (gca, 'xtick', my_icdf(xtick));

set(gca, 'xticklabel', xticklabel);

xlim(my_icdf([0.000006 0.1]));

xlabel ('False Positive Rate (FPR) [%]');



ytick = xtick;         

yticklabel = num2str(ytick * 100, '%g\n');

yticklabel = textscan(yticklabel, '%s'); 
yticklabel = yticklabel{1};

set (gca, 'ytick', my_icdf(ytick));

set (gca, 'yticklabel', yticklabel);

ylim(my_icdf([0.003 0.7]));

ylabel ('False Negative Rate (FNR) [%]')

grid on;

box on;

axis square;

axis manual;


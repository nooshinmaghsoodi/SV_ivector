function fusionScoring(inputSet)
global params;

detail = strsplit(params.fusionDetail, '_');
fusion_type = detail{1};
parts = strsplit(detail{2}, '-');
if (strcmp(fusion_type,'feature'))
    for i=1:length(parts)
        fname = parts{i};
        if (strncmp(fname, 'PLP', 3) || strncmp(fname, 'MFCC', 3))
            fname = [fname '_E_D_A'];
        end
        features = load (['scores' filesep fname '_' inputSet.gender '_' params.paramPrefix '.mat']);
        pos_num = features.score_det{2};
        neg_num = features.score_det{3};
        if (i==1)
            scores = features.score_det{1};
        else 
            scores = scores + features.score_det{1};
        end
        
    end
    score_det{1}=scores;
    score_det{2}=pos_num;
    score_det{3}=neg_num;
    save(['scores/features_' inputSet.gender '_' params.paramPrefix '.mat'], 'score_det');
else
    if (strcmp(fusion_type,'method'))
        unnorm = load (['scores/' parts{1} '_E_D_A_' inputSet.gender '_NormLen_unnorm-300_NormLen_ldaf-300.mat']);
        uplda = load (['scores/' parts{1} '_E_D_A_' inputSet.gender '_NormLen_uplda-300_NormLen_ldaf-300.mat']);
        scores= (unnorm.score_det{1} + uplda.score_det{1})/2;
        pos_num = unnorm.score_det{2};
        neg_num = unnorm.score_det{3};

    else
      if (strcmp(fusion_type,'all'))
          unnorm = load (['scores/features_' inputSet.gender '_NormLen_unnorm-300_NormLen_ldaf-300.mat']);
          uplda = load (['scores/features_' inputSet.gender '_NormLen_uplda-300_NormLen_ldaf-300.mat']);
          scores= (unnorm.score_det{1} + uplda.score_det{1})/2;
          pos_num = unnorm.score_det{2};
          neg_num = unnorm.score_det{3};
      end
    end
end
% figure
[eer, minDcf08, minDcf10] = compute_eer(scores, [ones(pos_num, 1); zeros(neg_num, 1)], true); % IV averaging
prefixes = getPrefixes();
rocPath = [prefixes.ivectorOutputDir prefixes.paramPrefix filesep 'roc.fig'];
% saveas(gcf, rocPath, 'fig');

fprintf(['Test for ' inputSet.gender ' finished, EER : %f, MinDCF08 : %f, , MinDCF10 : %f\n'], eer, minDcf08, minDcf10);

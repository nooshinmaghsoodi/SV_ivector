function [ cov_sum_inv]= up_lda_params( cov_sum) % [ V, cov_sum_inv, cov_covt_sum_inv]
cov_sum= cov_sum/ 150;
%covMats = cellfun(@(x) x/dim,covMats,'UniformOutput',false);
%cov_sum = cov_sum{1};
cov_sum_inv = cov_sum ^ -1;
%cov_sum_inv = cov_sum_inv/dim;

%covTrans = cellfun(@transpose,covMats,'UniformOutput',false);
%cov_covt = cellfun(@(x, y) x*y, covMats, covTrans,'UniformOutput',false);
%cov_covt_sum = my_cell_sum( cov_covt);
%
%cov_covt_sum_inv = cov_covt_sum ^ -1;
%cov_covt_sum_inv = cov_covt_sum_inv/(dim);
%V = chol(cov_covt_sum_inv, 'lower');


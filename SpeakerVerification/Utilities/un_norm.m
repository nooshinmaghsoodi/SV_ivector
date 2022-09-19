function mapping = un_norm( covMat, within_cov, with_WCCN )
if (with_WCCN)
   trace(covMat+ within_cov)
   trace(within_cov) 
   covMat = (covMat+ within_cov)^-1;
   mapping.W = chol(covMat, 'lower');
   
else
   covMat = covMat^-1;
   mapping.W = chol(covMat, 'lower');
end
  
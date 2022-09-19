function y = my_icdf(x)
% computes the inverse of cumulative distribution function in x
y = -sqrt(2).*erfcinv(2 * ( x + eps));
y(isinf(y)) = nan;
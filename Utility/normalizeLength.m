function matrix = normalizeLength(matrix, dim)
if (nargin == 1)
    dim = 1;
end
if (dim == 1)
    matrix = bsxfun(@rdivide, matrix, sqrt(sum(matrix.^2, 2)));
else
    matrix = bsxfun(@rdivide, matrix, sqrt(sum(matrix.^2)));
end
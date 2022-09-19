function W = zda(x_data, y_data)

mean_x = mean(x_data, 2);
x_data = bsxfun(@minus, x_data, mean_x);
% y_data = y_data(:, 1 : 50 : end);
y_data = bsxfun(@minus, y_data, mean_x);

x_cov = (x_data * x_data') / size(x_data, 2);
y_cov = (y_data * y_data') / size(y_data, 2);

[W, D] = eig(y_cov, x_cov); % generalized EVD 
[D, I] = sort(diag(D), 'descend');
W = W(:, I(1));
W = W / norm(W);
new_x = W' * x_data;
new_y = W' * y_data;
if (mean(new_y) > mean(new_x))
    W = -W;
end

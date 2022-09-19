function avout = my_cell_average (input_cell)

cell_size = size(input_cell,2);
sumout = input_cell{1};
for i=2:cell_size
    sumout = sumout + input_cell{i};
end
avout = sumout/cell_size;
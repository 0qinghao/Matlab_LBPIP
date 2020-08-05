function [img_cell, repeat_height, repeat_width] = img_mat2cell(img_mat, BLOCK_SIZE) 
    [rr,cc,dd] = size(img_mat);
    %%% Turn into cells 
    repeat_height = rr/BLOCK_SIZE;
    repeat_width = cc/BLOCK_SIZE;
    repeat_height_mat = repmat(BLOCK_SIZE, [1 repeat_height]);
    repeat_width_mat = repmat(BLOCK_SIZE, [1 repeat_width]);
    img_cell = mat2cell(img_mat, repeat_height_mat, repeat_width_mat, dd);
end
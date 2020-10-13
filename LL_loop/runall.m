load('./Luma.mat');
log = Luma;
filecnt = length(Luma);

for f = 15:15
    tic

    srcy = Luma(f).Ydata;

    [size_all_b, blk_size_sum_b, split_frame_b, mode_frame_b, CTU_bits_all_b] = encode_main_blk(srcy);
    % [size_all_l, blk_size_sum_l, split_frame_l, mode_frame_l, CTU_bits_all_l] = encode_main_loop(srcy);
    [size_all_c, blk_size_sum_c, split_frame_c, mode_frame_c, CTU_bits_all_c] = encode_main_comb(srcy);

    log(f).size_block = size_all_b;
    % log(f).size_loop = size_all_l;
    log(f).size_comb = size_all_c;
    log(f).partition_block = blk_size_sum_b;
    % log(f).patition_loop = blk_size_sum_l;
    log(f).prtition_comb = blk_size_sum_c;
    log(f).split_frame_block = split_frame_b;
    % log(f).split_frame_loop = split_frame_l;
    log(f).split_frame_comb = split_frame_c;
    log(f).mode_frame_block = mode_frame_b;
    % log(f).mode_frame_loop = mode_frame_l;
    log(f).mode_frame_comb = mode_frame_c;

    disp(f)

    toc

end

save('./allLOG.mat', 'log');

load('./Luma.mat');
log = Luma;
filecnt = length(Luma);

parfor f = 1:filecnt
    tic

    srcy = Luma(f).Ydata;

    % [size_all_b, blk_size_sum_b, split_frame_b, mode_frame_b, CTU_bits_all_b] = encode_main_blk(srcy);
    [size_all_c, blk_size_sum_c, split_frame_c, mode_frame_c, CTU_bits_all_c] = encode_main_comb(srcy);
    % [size_all_c_loop21, blk_size_sum_c_loop21, split_frame_c_loop21, mode_frame_c_loop21, CTU_bits_all_c_loop21] = encode_main_comb_loop21(srcy);

    % log(f).size_block = size_all_b;
    log(f).size_comb = size_all_c;
    % log(f).size_comb_loop21 = size_all_c_loop21;

    % log(f).partition_block = blk_size_sum_b;
    log(f).prtition_comb = blk_size_sum_c;
    % log(f).prtition_comb_loop21 = blk_size_sum_c_loop21;

    % log(f).split_frame_block = split_frame_b;
    log(f).split_frame_comb = split_frame_c;
    % log(f).split_frame_comb_loop21 = split_frame_c_loop21;

    % log(f).mode_frame_block = mode_frame_b;
    log(f).mode_frame_comb = mode_frame_c;
    % log(f).mode_frame_comb_loop21 = mode_frame_c_loop21;

    % log(f).CTU_bits_block = CTU_bits_all_b;
    log(f).CTU_bits_comb = CTU_bits_all_c;
    % log(f).CTU_bits_comb_loop21 = CTU_bits_all_c_loop21;

    disp(f)

    toc

end

save('./allLOG_combloop24.mat', 'log');

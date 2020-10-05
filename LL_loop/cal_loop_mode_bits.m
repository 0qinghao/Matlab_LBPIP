function loop_mode_bits = cal_loop_mode_bits(mode_blk_loop)
    [PU, ~] = size(mode_blk_loop);
    mode_1d = mode_blk_loop(1:PU - 3, PU);

    mode_1d_diff = diff([0, mode_1d']);
    loop_mode_bits = huffman_testsize(mode_1d_diff);
end

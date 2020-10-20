function rdc = cal_rdc_blk(res, mode_blk, mode_bits)
    % res_order = res(:);
    res_order = ResidualCodingOrder(res, 0, mode_blk - 1, 0);
    res_bits = huffman_testsize(res_order);

    rdc = res_bits + mode_bits;
end

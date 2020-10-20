function rdc = cal_rdc(res, mode_bits)
    res_order = res(:);
    res_bits = huffman_testsize(res_order);

    rdc = res_bits + mode_bits;
end

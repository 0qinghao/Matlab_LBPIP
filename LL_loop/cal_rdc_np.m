function rdc = cal_rdc_np(res, mode_bits, pred_range, rdc_deep_layer, rdc_ind, mask)
    res_order = res(pred_range);
    res_bits = huffman_testsize(res_order);

    switch mask
        case 1111
            rdc_deep_layer_m = 0;
        case 0111
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 0);

        case 1011
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 1);

        case 1101
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 2);

        case 1110
            rdc_deep_layer_m = rdc_deep_layer(rdc_ind * 4 - 3 + 3);
    end

    rdc = res_bits + mode_bits + rdc_deep_layer_m;
end

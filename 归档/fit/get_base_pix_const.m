function [base_pix, dec_base_pix, b4_enc_base_pix] = get_base_pix_const(yuv_block, SIZE, quality)
    % yuv_block: 以 SIZE*SIZE 为大小的, 3 色彩空间的像素信息
    % quality: jpeg 压缩时量化参数 1-100
    % base_pix: 从 yuv_block 中提取的完全准确的数值
    % dec_base_pix: 经过 dct - 量化 - 去量化 - idct 后的带误差的关键像素
    % b4_enc_base_pix: 送去 Huffman 编码的数据
    initGlobals(quality);
    [~, ~, dd] = size(yuv_block);

    switch SIZE
        case 20
            base_index = [[43:5:60]', 100 + [43:5:60]', 200 + [43:5:60]', 300 + [43:5:60]'];
            base_pix = zeros(SIZE / 5, SIZE / 5, dd);
        case 40
            base_index = [[83:5:120]', 200 + [83:5:120]', 400 + [83:5:120]', 600 + [83:5:120]', 800 + [83:5:120]', 1000 + [83:5:120]', 1200 + [83:5:120]', 1400 + [83:5:120]'];
            base_pix = zeros(SIZE / 5, SIZE / 5, dd);
    end
    dec_base_pix = base_pix;
    b4_enc_base_pix = base_pix;

    for i = 1:dd
        base_pix(:, :, i) = yuv_block(base_index + (i - 1) * SIZE^2);

        dct_temp = dct2(base_pix(:, :, i) - 128);
        b4_enc_base_pix(:, :, i) = quantize(dct_temp, i);

        deQ_temp = dequantize(b4_enc_base_pix(:, :, i), i);
        dec_base_pix(:, :, i) = round(idct2(deQ_temp) + 128);
    end
end

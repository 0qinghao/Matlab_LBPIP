% function [PSNR] = code_rec(inputName, baseName, fixvalName, modeName, outputName, Q_fix)
function [PSNR] = code_linespace(inputName, baseName, fixvalName, modeName, outputName, TH_fix, TH_div, quality)
    img_src = imread(inputName);
    yuv_src = jpeg_rgb2ycbcr(img_src);
    global mode_sum;
    mode_sum = 0;

    %按分块处理的思路写代码
    MAX_BLOCK_SIZE = 40;
    [yuv_cell, repeat_height, repeat_width] = img_mat2cell(yuv_src, MAX_BLOCK_SIZE);
    decode_cell = cell(repeat_height, repeat_width);
    b4_enc_base_pix_cell = cell(repeat_height, repeat_width);
    b4_enc_base_fixval_cell = cell(repeat_height, repeat_width);
    b4_enc_fixval_cell = cell(repeat_height, repeat_width);
    for x = 1:repeat_height
        for y = 1:repeat_width
            yuv_block = yuv_cell{x, y};
            % [b4_enc_base_pix, b4_enc_base_fixval, b4_enc_fixval, pre_mode, decode_block] = encode_top(yuv_block, Q_fix);
            [b4_enc_base_pix, b4_enc_base_fixval, b4_enc_fixval, pre_mode, decode_block] = encode_top_linespace(yuv_block, TH_fix, TH_div, quality);
            decode_cell{x, y} = decode_block;
            b4_enc_base_pix_cell{x, y} = b4_enc_base_pix;
            b4_enc_base_fixval_cell{x, y} = b4_enc_base_fixval;
            b4_enc_fixval_cell{x, y} = b4_enc_fixval;
            % disp(['x=', int2str(x), ',y=', int2str(y), ',mode=', int2str(pre_mode)]);
        end
    end

    encode_base_pix(b4_enc_base_pix_cell, baseName);
    encode_fixval(b4_enc_base_fixval_cell, b4_enc_fixval_cell, fixvalName);
    % encode_mode(pre_mode, modeName);

    % 评测部分
    decode_yuv = uint8(cell2mat(decode_cell));
    decode_rgb = jpeg_ycbcr2rgb(decode_yuv);
    PSNR = psnr(img_src, decode_rgb);
    mode_sum

    imwrite(decode_rgb, outputName);
end

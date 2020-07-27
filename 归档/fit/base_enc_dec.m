function [decode_yuv_base] = base_enc_dec(yuv_base, baseName)
    CELL_SIZE = 8;
    % CELL_SIZE = 4;
    y_base = yuv_base(:, :, 1);
    u_base = yuv_base(:, :, 2);
    v_base = yuv_base(:, :, 3);
    %%% Turn into cells
    repeat_height = size(y_base, 1) / CELL_SIZE;
    repeat_width = size(y_base, 2) / CELL_SIZE;
    repeat_height_mat = repmat(CELL_SIZE, [1 repeat_height]);
    repeat_width_mat = repmat(CELL_SIZE, [1 repeat_width]);
    y_sub_base = mat2cell(y_base, repeat_height_mat, repeat_width_mat);
    u_sub_base = mat2cell(u_base, repeat_height_mat, repeat_width_mat);
    v_sub_base = mat2cell(v_base, repeat_height_mat, repeat_width_mat);
    decode_y_sub_base = y_sub_base;
    decode_u_sub_base = u_sub_base;
    decode_v_sub_base = v_sub_base;
    fid = fopen(baseName, 'w');
    writeHeader(fid, size(y_base, 1), size(y_base, 2));
    lastDC(1) = 0;
    lastDC(2) = 0;
    lastDC(3) = 0;
    for i = 1:repeat_height
        for j = 1:repeat_width
            y_sub_base{i, j} = dct2(double(y_sub_base{i, j}) - 128);
            y_sub_base{i, j} = quantize(y_sub_base{i, j}, 'lum');
            % lastDC(1) = huffman4x4(fid, y_sub_base{i, j}, lastDC(1), 1, 1);
            lastDC(1) = huffman(fid, y_sub_base{i, j}, lastDC(1), 1, 1);
            u_sub_base{i, j} = dct2(double(u_sub_base{i, j}) - 128);
            u_sub_base{i, j} = quantize(u_sub_base{i, j}, 'chrom');
            % lastDC(2) = huffman4x4(fid, u_sub_base{i, j}, lastDC(2), 2, 2);
            lastDC(2) = huffman(fid, u_sub_base{i, j}, lastDC(2), 2, 2);
            v_sub_base{i, j} = dct2(double(v_sub_base{i, j}) - 128);
            v_sub_base{i, j} = quantize(v_sub_base{i, j}, 'chrom');
            % lastDC(3) = huffman4x4(fid, v_sub_base{i, j}, lastDC(3), 2, 2);
            lastDC(3) = huffman(fid, v_sub_base{i, j}, lastDC(3), 2, 2);

            decode_y_sub_base{i, j} = dequantize(y_sub_base{i, j}, 'lum');
            decode_y_sub_base{i, j} = uint8(idct2(decode_y_sub_base{i, j}) + 128);
            decode_u_sub_base{i, j} = dequantize(u_sub_base{i, j}, 'chrom');
            decode_u_sub_base{i, j} = uint8(idct2(decode_u_sub_base{i, j}) + 128);
            decode_v_sub_base{i, j} = dequantize(v_sub_base{i, j}, 'chrom');
            decode_v_sub_base{i, j} = uint8(idct2(decode_v_sub_base{i, j}) + 128);
        end
    end
    flashBuffer(fid);
    writeEOI(fid);
    fclose(fid);
    decode_yuv_base(:, :, 1) = cell2mat(decode_y_sub_base);
    decode_yuv_base(:, :, 2) = cell2mat(decode_u_sub_base);
    decode_yuv_base(:, :, 3) = cell2mat(decode_v_sub_base);
    % src里面的0全部变成1，据统计不多。这样可以靠是不是0方便后面非常多的处理
    % decode_yuv_base = rm_zero(decode_yuv_base);
end

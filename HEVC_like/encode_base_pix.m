function encode_base_pix(b4_enc_base_pix_cell, baseName)
    [repeat_height, repeat_width] = size(b4_enc_base_pix_cell);
    lastDC(1) = 0;
    lastDC(2) = 0;
    lastDC(3) = 0;
    fid = fopen(baseName, 'w');
    for i = 1:repeat_height
        for j = 1:repeat_width
            yuv = b4_enc_base_pix_cell{i, j};
            lastDC(1) = huffman(fid, yuv(:, :, 1), lastDC(1), 1, 1);

            lastDC(2) = huffman(fid, yuv(:, :, 2), lastDC(2), 2, 2);

            lastDC(3) = huffman(fid, yuv(:, :, 3), lastDC(3), 2, 2);
        end
    end

    flashBuffer(fid);

    writeEOI(fid);

    fclose(fid);
end

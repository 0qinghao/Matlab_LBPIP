    initGlobals(100);
    testp = uint8(repmat(linspace(0, 254, 8), 8, 1));
    % testp = (repmat(linspace(0, 254, 8), 8, 1));

    dctp = dct2(testp - 127);

    for Q = 30:40

        dctqp = quantize_fixval(dctp, 1, Q);

        fid = fopen(['huffmanp', int2str(Q)], 'w');
        huffman_fix(fid, dctqp);
        fclose(fid);

        deq = dequantize_fixval(dctqp, 1, Q);
        dedct = idct2(deq) + 127;

        rebuild(:, :, Q) = round(dedct);
        PSNR(Q) = psnr(uint8(rebuild(:, :, Q)), uint8(testp));
    end

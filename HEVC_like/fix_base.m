% function [fixed_base, b4_enc_base_fixval] = fix_base(base_pix, dec_base_pix, Q_fix, SIZE)
function [fixed_base, b4_enc_base_fixval] = fix_base(base_pix, dec_base_pix, TH_fix, SIZE)
    [rr, cc, dd] = size(base_pix);
    b4_enc_base_fixval = zeros(rr, cc, dd);
    dec_base_fixval = b4_enc_base_fixval;
    fixed_base = zeros(SIZE, SIZE, dd);
    switch SIZE
        case 20
            base_index = [[43:5:60]', 100 + [43:5:60]', 200 + [43:5:60]', 300 + [43:5:60]'];
        case 40
            base_index = [[83:5:120]', 200 + [83:5:120]', 400 + [83:5:120]', 600 + [83:5:120]', 800 + [83:5:120]', 1000 + [83:5:120]', 1200 + [83:5:120]', 1400 + [83:5:120]'];
    end

    fixval = base_pix - dec_base_pix;

    for i = 1:dd
        b4_enc_base_fixval(:, :, i) = round(fixval(:, :, i) ./ TH_fix);

        dec_base_fixval(:, :, i) = round(b4_enc_base_fixval(:, :, i) .* TH_fix);

        fixed_base(base_index + (i - 1) * SIZE^2) = dec_base_fixval(:, :, i) + dec_base_pix(:, :, i);
    end
    % for i = 1:dd
    %     dct_temp = dct2(fixval(:, :, i));
    %     b4_enc_base_fixval(:, :, i) = quantize_fixval(dct_temp, i, Q_fix);

    %     deQ_temp = dequantize_fixval(b4_enc_base_fixval(:, :, i), i, Q_fix);
    %     dec_base_fixval(:, :, i) = round(idct2(deQ_temp));

    %     fixed_base(base_index + (i - 1) * SIZE^2) = dec_base_fixval(:, :, i) + dec_base_pix(:, :, i);
    %     % fixed_base(base_index + (i - 1) * SIZE^2) = dec_base_pix(:, :, i);
    % end
end

function [err, pred, sae, mode, preview] = h264intra_test_4(inputName)
    clear err pred sae mode preview
    rgb = imread(inputName);
    yuv = double(jpeg_rgb2ycbcr(rgb));
    lum = yuv(:, :, 1);
    err = {}; pred = {}; sae = {}; mode = {}; preview = {};
    for x = 2:4:1080 - 7
        for y = 2:4:1920 - 7
            src = lum(x:x + 3, y:y + 3);
            T = lum(x - 1, y:y + 7);
            L = lum(x:x + 7, y - 1);
            LT = lum(x - 1, y - 1);

            [err{end + 1}, pred{end + 1}, sae{end + 1}, mode{end + 1}] = mode_select_4(L, T, LT, src);
            preview{end + 1} = [LT, T(1:4); [L(1:4), src]];
        end
    end
    sae = cell2mat(sae);
    mode = cell2mat(mode);
end

function [err, pred, sae] = pred_vert_4(L, T, LT, src)
    pred = ones(4, 1) * T(1:4);
    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_horz_4(L, T, LT, src)
    pred = L(1:4) * ones(1, 4);
    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_dc_4(L, T, LT, src)
    pred = (bitshift(sum(L(1:4)) + sum(T(1:4)) + 4, -3)) * ones(4, 4);
    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_ddl_4(L, T, LT, src)
    a = bitshift(T(1) + 2 * T(2) + T(3) + 2, -2);
    b = bitshift(T(2) + 2 * T(3) + T(4) + 2, -2);
    c = bitshift(T(3) + 2 * T(4) + T(5) + 2, -2);
    d = bitshift(T(4) + 2 * T(5) + T(6) + 2, -2);
    e = bitshift(T(5) + 2 * T(6) + T(7) + 2, -2);
    f = bitshift(T(6) + 2 * T(7) + T(8) + 2, -2);
    g = bitshift(T(7) + 3 * T(8) + 2, -2);

    pred(1, 1) = a; pred(1, 2) = b; pred(1, 3) = c; pred(1, 4) = d;
    pred(2, 1) = b; pred(2, 2) = c; pred(2, 3) = d; pred(2, 4) = e;
    pred(3, 1) = c; pred(3, 2) = d; pred(3, 3) = e; pred(3, 4) = f;
    pred(4, 1) = d; pred(4, 2) = e; pred(4, 3) = f; pred(4, 4) = g;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_ddr_4(L, T, LT, src)
    a = bitshift(L(4) + 2 * L(3) + L(2) + 2, -2);
    b = bitshift(L(3) + 2 * L(2) + L(1) + 2, -2);
    c = bitshift(L(2) + 2 * L(1) + LT + 2, -2);
    d = bitshift(L(1) + 2 * LT + T(1) + 2, -2);
    e = bitshift(LT + 2 * T(1) + T(2) + 2, -2);
    f = bitshift(T(1) + 2 * T(2) + T(3) + 2, -2);
    g = bitshift(T(1) + 2 * T(3) + T(4) + 2, -2);

    pred(1, 1) = d; pred(1, 2) = e; pred(1, 3) = f; pred(1, 4) = g;
    pred(2, 1) = c; pred(2, 2) = d; pred(2, 3) = e; pred(2, 4) = f;
    pred(3, 1) = b; pred(3, 2) = c; pred(3, 3) = d; pred(3, 4) = e;
    pred(4, 1) = a; pred(4, 2) = b; pred(4, 3) = c; pred(4, 4) = d;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_vr_4(L, T, LT, src)
    a = bitshift(LT + T(1) + 1, -1);
    b = bitshift(T(1) + T(2) + 1, -1);
    c = bitshift(T(2) + T(3) + 1, -1);
    d = bitshift(T(3) + T(4) + 1, -1);
    e = bitshift(L(1) + 2 * LT + T(1) + 2, -2);
    f = bitshift(LT + 2 * T(1) + T(2) + 2, -2);
    g = bitshift(T(1) + 2 * T(2) + T(3) + 2, -2);
    h = bitshift(T(2) + 2 * T(3) + T(4) + 2, -2);
    i = bitshift(LT + 2 * L(1) + L(2) + 2, -2);
    j = bitshift(L(1) + 2 * L(2) + L(3) + 2, -2);

    pred(1, 1) = a; pred(1, 2) = b; pred(1, 3) = c; pred(1, 4) = d;
    pred(2, 1) = e; pred(2, 2) = f; pred(2, 3) = g; pred(2, 4) = h;
    pred(3, 1) = i; pred(3, 2) = a; pred(3, 3) = b; pred(3, 4) = c;
    pred(4, 1) = j; pred(4, 2) = e; pred(4, 3) = f; pred(4, 4) = g;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_hd_4(L, T, LT, src)
    a = bitshift(LT + L(1) + 1, -1);
    b = bitshift(L(1) + 2 * LT + T(1) + 2, -2);
    c = bitshift(LT + 2 * T(1) + T(2) + 2, -2);
    d = bitshift(T(1) + 2 * T(2) + T(3) + 2, -2);
    e = bitshift(L(1) + L(2) + 1, -1);
    f = bitshift(LT + 2 * L(1) + L(2) + 2, -2);
    g = bitshift(L(2) + L(3) + 1, -1);
    h = bitshift(L(1) + 2 * L(2) + L(3) + 2, -2);
    i = bitshift(L(3) + L(4) + 1, -1);
    j = bitshift(L(2) + 2 * L(3) + L(4) + 2, -2);

    pred(1, 1) = a; pred(1, 2) = b; pred(1, 3) = c; pred(1, 4) = d;
    pred(2, 1) = e; pred(2, 2) = f; pred(2, 3) = a; pred(2, 4) = b;
    pred(3, 1) = g; pred(3, 2) = h; pred(3, 3) = e; pred(3, 4) = f;
    pred(4, 1) = i; pred(4, 2) = j; pred(4, 3) = g; pred(4, 4) = h;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_vl_4(L, T, LT, src)
    a = bitshift(T(1) + T(2) + 1, -1);
    b = bitshift(T(2) + T(3) + 1, -1);
    c = bitshift(T(3) + T(4) + 1, -1);
    d = bitshift(T(4) + T(5) + 1, -1);
    e = bitshift(T(5) + T(6) + 1, -1);
    f = bitshift(T(1) + 2 * T(2) + T(3) + 2, -2);
    g = bitshift(T(2) + 2 * T(3) + T(4) + 2, -2);
    h = bitshift(T(3) + 2 * T(4) + T(5) + 2, -2);
    i = bitshift(T(4) + 2 * T(5) + T(6) + 2, -2);
    j = bitshift(T(5) + 2 * T(6) + T(7) + 2, -2);

    pred(1, 1) = a; pred(1, 2) = b; pred(1, 3) = c; pred(1, 4) = d;
    pred(2, 1) = f; pred(2, 2) = g; pred(2, 3) = h; pred(2, 4) = i;
    pred(3, 1) = b; pred(3, 2) = c; pred(3, 3) = d; pred(3, 4) = e;
    pred(4, 1) = g; pred(4, 2) = h; pred(4, 3) = i; pred(4, 4) = j;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_hu_4(L, T, LT, src)
    a = bitshift(L(1) + L(2) + 1, -1);
    b = bitshift(L(1) + 2 * L(2) + L(3) + 2, -2);
    c = bitshift(L(2) + L(3) + 1, -1);
    d = bitshift(L(2) + 2 * L(3) + L(4) + 2, -2);
    e = bitshift(L(3) + L(4) + 1, -1);
    f = bitshift(L(3) + 3 * L(4) + 2, -2);
    g = L(4);

    pred(1, 1) = a; pred(1, 2) = b; pred(1, 3) = c; pred(1, 4) = d;
    pred(2, 1) = c; pred(2, 2) = d; pred(2, 3) = e; pred(2, 4) = f;
    pred(3, 1) = e; pred(3, 2) = f; pred(3, 3) = g; pred(3, 4) = g;
    pred(4, 1) = g; pred(4, 2) = g; pred(4, 3) = g; pred(4, 4) = g;

    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae, mode] = mode_select_4(L, T, LT, src)
    [err1, pred1, sae1] = pred_vert_4(L, T, LT, src);
    [err2, pred2, sae2] = pred_horz_4(L, T, LT, src);
    [err3, pred3, sae3] = pred_dc_4(L, T, LT, src);
    [err4, pred4, sae4] = pred_ddl_4(L, T, LT, src);
    [err5, pred5, sae5] = pred_ddr_4(L, T, LT, src);
    [err6, pred6, sae6] = pred_vr_4(L, T, LT, src);
    [err7, pred7, sae7] = pred_hd_4(L, T, LT, src);
    [err8, pred8, sae8] = pred_vl_4(L, T, LT, src);
    [err9, pred9, sae9] = pred_hu_4(L, T, LT, src);

    [~, idx] = min([sae1 sae2 sae3 sae4 sae5 sae6 sae7 sae8 sae9]);

    switch idx
        case 1
            sae = sae1;
            err = err1;
            pred = pred1;
            mode = 0;
        case 2
            sae = sae2;
            err = err2;
            pred = pred2;
            mode = 1;
        case 3
            sae = sae3;
            err = err3;
            pred = pred3;
            mode = 2;
        case 4
            sae = sae4;
            err = err4;
            pred = pred4;
            mode = 3;
        case 5
            sae = sae5;
            err = err5;
            pred = pred5;
            mode = 4;
        case 6
            sae = sae6;
            err = err6;
            pred = pred6;
            mode = 5;
        case 7
            sae = sae7;
            err = err7;
            pred = pred7;
            mode = 6;
        case 8
            sae = sae8;
            err = err8;
            pred = pred8;
            mode = 7;
        case 9
            sae = sae9;
            err = err9;
            pred = pred9;
            mode = 8;
    end
end

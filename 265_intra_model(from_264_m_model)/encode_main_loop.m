function [Seq_r, bits_frame, mode_all, icp_all_block, err_all_block, dctq_all_block] = encode_main_loop(Seq, Quant)
    initGlobals(80);
    Seq = double(Seq);

    global QP h w
    % load table.mat

    [h, w] = size(Seq);
    QP = Quant;

    [bits_frame2, mode_all, Seq_r2, icp_all_block, err_all_block, dctq_all_block] = intra_16(Seq);

    bits_frame = bits_frame2;
    Seq_r = uint8(Seq_r2(2:h - 32, 2:w - 32));
end

%--------------------------------------------------------------
function [bits_frame, mode_all, Seq_r, icp_all_block, err_all_block, dctq_all_block] = intra_16(Seq)
    global h w
    bits_frame = 0;
    % total_sae = 0;
    mode_all = [];
    Seq_r = nan(h, w);
    Seq_r(1, :) = 128;
    Seq_r(:, 1) = 128;

    blk_ind = 1;
    for i = 2:16:h - 32
        for j = 2:16:w - 32
            icp_loop = nan(16, 31);
            for k = 16:-1:1
                [icp, pred, ~, mode] = mode_select_16(Seq, Seq_r, i, j, k);

                [Seq_r, icp_cq] = get_rebuild(icp, pred, i, j, k, Seq_r);
                icp_loop(16 - k + 1, 1:2 * k - 1) = icp_cq;
                % Seq_r(i:i + 15, j:j + 15) = icp_r + pred;
                % total_sae = total_sae + sae;
                mode_all(blk_ind, 17 - k) = mode;

                cnt = 16 - k;
                icp_blk(1 + cnt, 1 + cnt) = icp(k);
                dctq_blk(1 + cnt, 1 + cnt) = icp_cq(k);
                if (k ~= 1)
                    icp_blk(1 + cnt, 2 + cnt:16) = icp(k + 1:end);
                    icp_blk(2 + cnt:16, 1 + cnt) = icp(k - 1:-1:1);
                    dctq_blk(1 + cnt, 2 + cnt:16) = icp_cq(k + 1:end);
                    dctq_blk(2 + cnt:16, 1 + cnt) = icp_cq(k - 1:-1:1);
                end
            end
            bits = encode_icp_loop(icp_loop);
            bits_frame = bits_frame + bits;
            icp_all_block{blk_ind} = icp_blk;
            err_all_block{blk_ind} = Seq_r(i:i + 15, j:j + 15) - Seq(i:i + 15, j:j + 15);
            dctq_all_block{blk_ind} = dctq_blk;
            blk_ind = blk_ind + 1;
        end
    end
end
%--------------------------------------------------------
%% Transform, Quantization, Entropy coding
% transform = Integer transform
% Quantization = h.264
% VLC = CAVLC (H.264)

function [err_r, bits_mb] = code_block_16x16(err)

    global QP
    Q = QP;

    c = round(dct2(err));
    cq = round(c / Q);
    zz_cq = zigzag_2dto1d(cq);
    bits_mb = huffman(zz_cq);
    Wi = round(cq * Q);
    Y = round(idct2(Wi));
    err_r = Y;
end
function [err_r, bits_mb] = code_block(err)

    global QP

    [n, m] = size(err);

    bits_mb = '';

    for i = 1:4:n
        for j = 1:4:m
            c(i:i + 3, j:j + 3) = integer_transform(err(i:i + 3, j:j + 3));
            cq(i:i + 3, j:j + 3) = quantization(c(i:i + 3, j:j + 3), QP);
            [bits_b] = enc_cavlc(cq(i:i + 3, j:j + 3), 0, 0);
            bits_mb = [bits_mb bits_b];
            Wi = inv_quantization(cq(i:i + 3, j:j + 3), QP);
            Y = inv_integer_transform(Wi);
            err_r(i:i + 3, j:j + 3) = round(Y / 64);
        end
    end

end
%-------------------------------------------------------
%% 16x16 Horizontal prediciton

function [icp, pred, sae, mode] = mode_select_16(Seq, Seq_r, i, j, k)
    dst = Seq(i:i + 15, j:j + 15);
    [dst_1d] = get_dst_k_loop(dst, k);
    [PX, PY] = get_px_py(Seq_r, i, j, k);

    % Intra DC Prediction
    [pred_dc] = DC_Model_loop(k, PX, PY);

    % Intra Planar Prediction
    [pred_pl] = Planar_Model_loop(k, PX, PY);

    % Intra Angular Prediction
    [pred_ang] = Intra_Angular_Model_loop(PY, PX, k);

    pred_pixels{1} = pred_dc;
    pred_pixels{2} = pred_pl;
    pred_pixels{3} = pred_ang{1};
    pred_pixels{4} = pred_ang{2};
    pred_pixels{5} = pred_ang{3};
    pred_pixels{6} = pred_ang{4};
    pred_pixels{7} = pred_ang{5};
    pred_pixels{8} = pred_ang{6};
    pred_pixels{9} = pred_ang{7};
    pred_pixels{10} = pred_ang{8};
    pred_pixels{11} = pred_ang{9};
    pred_pixels{12} = pred_ang{10};
    pred_pixels{13} = pred_ang{11};
    pred_pixels{14} = pred_ang{12};
    pred_pixels{15} = pred_ang{13};
    pred_pixels{16} = pred_ang{14};
    pred_pixels{17} = pred_ang{15};
    pred_pixels{18} = pred_ang{16};
    pred_pixels{19} = pred_ang{17};
    pred_pixels{20} = pred_ang{18};
    pred_pixels{21} = pred_ang{19};
    pred_pixels{22} = pred_ang{20};
    pred_pixels{23} = pred_ang{21};
    pred_pixels{24} = pred_ang{22};
    pred_pixels{25} = pred_ang{23};
    pred_pixels{26} = pred_ang{24};
    pred_pixels{27} = pred_ang{25};
    pred_pixels{28} = pred_ang{26};
    pred_pixels{29} = pred_ang{27};
    pred_pixels{30} = pred_ang{28};
    pred_pixels{31} = pred_ang{29};
    pred_pixels{32} = pred_ang{30};
    pred_pixels{33} = pred_ang{31};
    pred_pixels{34} = pred_ang{32};
    pred_pixels{35} = pred_ang{33};

    for m = 1:35
        icp_all{m} = dst_1d - pred_pixels{m};
        sae_all(m) = sum(abs(icp_all{m}));
    end

    [sae, mode] = min(sae_all);
    icp = icp_all{mode};
    pred = pred_pixels{mode};
end

function [dst_1d] = get_dst_k_loop(dst, k)
    cnt = 16 - k + 1;

    if (k ~= 1)
        TOP = dst(cnt, cnt + 1:16);
        LEFT = dst(cnt + 1:16, cnt);
        TOPLEFT = dst(cnt, cnt);
        dst_1d = [LEFT(end:-1:1)', TOPLEFT, TOP];
    else
        dst_1d = dst(16, 16);
    end
end

function [PX, PY] = get_px_py(Seq_r, i, j, k)
    ind = 16 - k - 1;

    PY = Seq_r(i + ind, j + ind:j + 15);
    PX = Seq_r(i + ind:i + 15, j + ind);
end

function [Seq_r, cq] = get_rebuild(icp, pred, i, j, k, Seq_r)
    global QP
    Q = QP;

    c = round(dct(icp));
    cq = round(c / Q);
    Wi = round(cq * Q);
    Y = round(idct(Wi));
    icp_r = Y;

    rebuild_loop = pred + icp_r;

    if (k ~= 1)
        LEFT = rebuild_loop(k - 1:-1:1);
        TOPLEFT = rebuild_loop(k);
        TOP = rebuild_loop(k + 1:end);
    else
        TOPLEFT = rebuild_loop;
    end

    cnt = 16 - k;
    Seq_r(i + cnt, j + cnt) = TOPLEFT;
    if (k ~= 1)
        Seq_r(i + cnt, j + cnt + 1:j + 15) = TOP;
        Seq_r(i + cnt + 1:i + 15, j + cnt) = LEFT;
    end
end

function [Seq_r_comb, bits_frame_comb, mode_all_comb, cnt_blk_comb, cnt_loop_comb, icp_all_comb, err_all_comb, dctq_all_comb] = encode_main_comb(Seq, Quant)
    initGlobals(80);
    Seq = double(Seq);

    global QP h w

    [h, w] = size(Seq);
    QP = Quant;

    [bits_frame_comb, mode_all_comb, Seq_r_comb, cnt_blk_comb, cnt_loop_comb, icp_all_comb, err_all_comb, dctq_all_comb] = intra_16(Seq);

    Seq_r_comb = uint8(Seq_r_comb(2:h - 32, 2:w - 32));
end

%--------------------------------------------------------------
function [bits_frame, mode_all, Seq_r, cnt_blk, cnt_loop, icp_all, err_all, dctq_all] = intra_16(Seq)
    global h w
    bits_frame = 0;
    cnt_blk = 0;
    cnt_loop = 0;
    mode_all = {};
    Seq_r = nan(h, w);
    Seq_r(1, :) = 128;
    Seq_r(:, 1) = 128;

    blk_ind = 1;
    for i = 2:16:h - 32
        for j = 2:16:w - 32

            %%%%%%%%%%%%%%% loop 部分
            icp_loop_all = nan(16, 31);
            Seq_r_loop = Seq_r;
            for k = 16:-1:1
                [icp_loop, pred_loop, ~, mode_loop] = mode_select_16_loop(Seq, Seq_r_loop, i, j, k);

                [Seq_r_loop, icp_cq_loop] = get_rebuild(icp_loop, pred_loop, i, j, k, Seq_r_loop);
                icp_loop_all(16 - k + 1, 1:2 * k - 1) = icp_cq_loop;
                mode_all_loop(blk_ind, 17 - k) = mode_loop;

                cnt = 16 - k;
                icp_blk_loop(1 + cnt, 1 + cnt) = icp_loop(k);
                dctq_blk_loop(1 + cnt, 1 + cnt) = icp_cq_loop(k);
                if (k ~= 1)
                    icp_blk_loop(1 + cnt, 2 + cnt:16) = icp_loop(k + 1:end);
                    icp_blk_loop(2 + cnt:16, 1 + cnt) = icp_loop(k - 1:-1:1);
                    dctq_blk_loop(1 + cnt, 2 + cnt:16) = icp_cq_loop(k + 1:end);
                    dctq_blk_loop(2 + cnt:16, 1 + cnt) = icp_cq_loop(k - 1:-1:1);
                end
            end
            bits_loop = encode_icp_loop(icp_loop_all);
            %%%%%%%%%%%%%%% loop 部分

            %%%%%%%%%%%%%%% block 部分
            Seq_r_blk = Seq_r;
            [icp_blk, pred_blk, ~, mode_blk] = mode_select_16_blk(Seq, Seq_r_blk, i, j);
            [icp_r_blk, bits_blk, dctq_blk] = code_block_16x16(icp_blk);
            Seq_r_blk(i:i + 15, j:j + 15) = icp_r_blk + pred_blk;
            %%%%%%%%%%%%%%% block 部分

            if bits_blk <= bits_loop
                cnt_blk = cnt_blk + 1;
                Seq_r = Seq_r_blk;
                bits_frame = bits_frame + bits_blk;
                icp_all{blk_ind} = icp_blk;
                err_all{blk_ind} = Seq_r(i:i + 15, j:j + 15) - Seq(i:i + 15, j:j + 15);
                dctq_all{blk_ind} = dctq_blk;
                mode_all{blk_ind} = mode_blk;
            else
                cnt_loop = cnt_loop + 1;
                Seq_r = Seq_r_loop;
                bits_frame = bits_frame + bits_loop;
                icp_all{blk_ind} = icp_blk_loop;
                err_all{blk_ind} = Seq_r(i:i + 15, j:j + 15) - Seq(i:i + 15, j:j + 15);
                dctq_all{blk_ind} = dctq_blk_loop;
                mode_all{blk_ind} = mode_all_loop;
            end
            blk_ind = blk_ind + 1;
        end
    end
end

function [err_r, bits_mb, cq] = code_block_16x16(err)

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
%-------------------------------------------------------
function [icp, pred, sae, mode] = mode_select_16_blk(Seq, Seq_r, i, j)
    dst = Seq(i:i + 15, j:j + 15);
    PU = 16;
    PX = Seq_r(i - 1:i + 31, j - 1);
    PY = Seq_r(i - 1, j - 1:j + 31);
    % if all(isnan(PX(18:33)))
    %     PX(18:33) = PX(17);
    % end

    % Intra DC Prediction
    Intra_DC = DC_Model(PU, PX, PY);

    % Intra Planar Prediction
    Intra_Planar = Planar_Model(PU, PX, PY);

    % Intra Angular Prediction
    Intra_Angular = Intra_Angular_Model(double(PY), double(PX), PU);

    %       for j=1:n_mode
    pred_pixels{1} = Intra_DC;
    pred_pixels{2} = Intra_Planar;
    pred_pixels{3} = Intra_Angular{1};
    pred_pixels{4} = Intra_Angular{2};
    pred_pixels{5} = Intra_Angular{3};
    pred_pixels{6} = Intra_Angular{4};
    pred_pixels{7} = Intra_Angular{5};
    pred_pixels{8} = Intra_Angular{6};
    pred_pixels{9} = Intra_Angular{7};
    pred_pixels{10} = Intra_Angular{8};
    pred_pixels{11} = Intra_Angular{9};
    pred_pixels{12} = Intra_Angular{10};
    pred_pixels{13} = Intra_Angular{11};
    pred_pixels{14} = Intra_Angular{12};
    pred_pixels{15} = Intra_Angular{13};
    pred_pixels{16} = Intra_Angular{14};
    pred_pixels{17} = Intra_Angular{15};
    pred_pixels{18} = Intra_Angular{16};
    pred_pixels{19} = Intra_Angular{17};
    pred_pixels{20} = Intra_Angular{18};
    pred_pixels{21} = Intra_Angular{19};
    pred_pixels{22} = Intra_Angular{20};
    pred_pixels{23} = Intra_Angular{21};
    pred_pixels{24} = Intra_Angular{22};
    pred_pixels{25} = Intra_Angular{23};
    pred_pixels{26} = Intra_Angular{24};
    pred_pixels{27} = Intra_Angular{25};
    pred_pixels{28} = Intra_Angular{26};
    pred_pixels{29} = Intra_Angular{27};
    pred_pixels{30} = Intra_Angular{28};
    pred_pixels{31} = Intra_Angular{29};
    pred_pixels{32} = Intra_Angular{30};
    pred_pixels{33} = Intra_Angular{31};
    pred_pixels{34} = Intra_Angular{32};
    pred_pixels{35} = Intra_Angular{33};

    for m = 1:35
        icp_all{m} = dst - pred_pixels{m};
        sae_all(m) = sum(sum(abs(icp_all{m})));
    end

    [sae, mode] = min(sae_all);
    icp = icp_all{mode};
    pred = pred_pixels{mode};
end

function [icp, pred, sae, mode] = mode_select_16_loop(Seq, Seq_r, i, j, k)
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

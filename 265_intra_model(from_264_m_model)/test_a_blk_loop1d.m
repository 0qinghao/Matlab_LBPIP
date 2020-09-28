function [psnr_loop, bits_loop, mode_all_loop] = test_a_blk_loop1d(dst, top, left, tl)
    initGlobals(80);
    Seq = double(dst);
    % [h, w] = size(Seq);
    [psnr_loop, bits_loop, mode_all_loop] = intra_16(Seq, top, left, tl);
end

function [psnr_loop, bits_loop, mode_all_loop] = intra_16(Seq, top, left, tl)
    Seq_ex = [left, Seq];
    Seq_ex = [[tl, top]; Seq_ex];
    cntq = 1;
    for Q = 1:12
        %%%%%%%%%%%%%%% 2rd 部分 ( 2 维重建后，与一维的 rebuild 求 diff。传 2 维 dct + diff)
        % Seq_r_2rd = Seq_r;
        % for k = 16:-1:1
        %     [prederr_2rd, pred_2rd, ~, mode_2rd] = mode_select_16_loop(Seq, Seq_r_2rd, i, j, k);

        %     [Seq_r_2rd, ~, prederr_r_2rd] = get_rebuild(prederr_2rd, pred_2rd, i, j, k, Seq_r_2rd);
        %     mode_all_2rd(17 - k) = mode_2rd;

        %     cnt = 16 - k;
        %     prederr_blk_2rd(1 + cnt, 1 + cnt) = prederr_2rd(k);
        %     prederr_r_blk_2rd(1 + cnt, 1 + cnt) = prederr_r_2rd(k);
        %     if (k ~= 1)
        %         prederr_blk_2rd(1 + cnt, 2 + cnt:16) = prederr_2rd(k + 1:end);
        %         prederr_blk_2rd(2 + cnt:16, 1 + cnt) = prederr_2rd(k - 1:-1:1);
        %         prederr_r_blk_2rd(1 + cnt, 2 + cnt:16) = prederr_r_2rd(k + 1:end);
        %         prederr_r_blk_2rd(2 + cnt:16, 1 + cnt) = prederr_r_2rd(k - 1:-1:1);
        %     end
        % end
        % [prederr_2d_r_2rd, bits_prederr_2rd, dctq_2rd] = code_block_16x16(prederr_blk_2rd);
        % diff_2rd = prederr_r_blk_2rd - prederr_2d_r_2rd;
        % bits_diff_2rd = huffman(zigzag_2dto1d(round(dct2(diff_2rd))));
        % bits_2rd = bits_diff_2rd + bits_prederr_2rd;
        %%%%%%%%%%%%%%% 2rd 部分

        %%%%%%%%%%%%%%% loop 部分
        prederr_cq_loop_all = nan(16, 31);
        Seq_r_loop = Seq_ex;
        i = 2; j = 2;
        for k = 16:-1:1
            [prederr_loop, pred_loop, ~, mode_loop] = mode_select_16_loop(Seq_ex, Seq_r_loop, i, j, k);

            [Seq_r_loop, prederr_cq_loop, prederr_r_loop] = get_rebuild(prederr_loop, pred_loop, i, j, k, Seq_r_loop, Q);
            prederr_cq_loop_all(16 - k + 1, 1:2 * k - 1) = prederr_cq_loop;
            mode_all_loop(17 - k) = mode_loop;

            cnt = 16 - k;
            prederr_blk_loop(1 + cnt, 1 + cnt) = prederr_loop(k);
            dctq_blk_loop(1 + cnt, 1 + cnt) = prederr_cq_loop(k);
            if (k ~= 1)
                prederr_blk_loop(1 + cnt, 2 + cnt:16) = prederr_loop(k + 1:end);
                prederr_blk_loop(2 + cnt:16, 1 + cnt) = prederr_loop(k - 1:-1:1);
                dctq_blk_loop(1 + cnt, 2 + cnt:16) = prederr_cq_loop(k + 1:end);
                dctq_blk_loop(2 + cnt:16, 1 + cnt) = prederr_cq_loop(k - 1:-1:1);
            end
        end
        bits_loop(cntq) = encode_prederr_loop(prederr_cq_loop_all);
        psnr_loop(cntq) = psnr(uint8(Seq), uint8(Seq_r_loop(2:17, 2:17)));
        cntq = cntq + 1;
        %%%%%%%%%%%%%%% loop 部分

        % if (bits_looperr_r < bits_blk && bits_looperr_r < bits_loop)
        %     bits_frame = bits_frame + bits_looperr_r;
        %     cnt_err_r = cnt_err_r + 1;
        %     blk_ind
        %     cnt_err_r
        %     bits_looperr_r
        %     bits_loop
        % elseif bits_blk <= bits_loop
    end
end

function [err_r, bits_mb, cq] = code_block_16x16(err, Q)

    c = round(dct2(err));
    cq = round(c / Q);
    zz_cq = zigzag_2dto1d(cq);
    bits_mb = huffman(zz_cq);
    Wi = round(cq * Q);
    Y = round(idct2(Wi));
    err_r = Y;
end

function [prederr, pred, sae, mode] = mode_select_16_blk(Seq, top, left, tl)
    dst = Seq;
    PU = 16;
    PX = [tl; left; repmat(left(end), PU, 1)];
    PY = [tl, top, repmat(top(end), 1, PU)];
    Intra_DC = DC_Model(PU, PX, PY);
    Intra_Planar = Planar_Model(PU, PX, PY);
    Intra_Angular = Intra_Angular_Model(PY, PX, PU);
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
        prederr_all{m} = dst - pred_pixels{m};
        sae_all(m) = sum(sum(abs(prederr_all{m})));
    end
    [sae, mode] = min(sae_all);
    prederr = prederr_all{mode};
    pred = pred_pixels{mode};
end

function [prederr, pred, sae, mode] = mode_select_16_loop(Seq, Seq_r, i, j, k)
    dst = Seq(i:i + 15, j:j + 15);
    [dst_1d] = get_dst_k_loop(dst, k);
    [PX, PY] = get_px_py(Seq_r, i, j, k);
    [pred_dc] = DC_Model_loop(k, PX, PY);
    [pred_pl] = Planar_Model_loop(k, PX, PY);
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
        prederr_all{m} = dst_1d - pred_pixels{m};
        sae_all(m) = sum(abs(prederr_all{m}));
    end
    [sae, mode] = min(sae_all);
    prederr = prederr_all{mode};
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

function [Seq_r, cq, prederr_r] = get_rebuild(prederr, pred, i, j, k, Seq_r, Q)
    % c = round((prederr));
    c = round(dct(prederr));
    cq = round(c / Q);
    Wi = round(cq * Q);
    % Y = round((Wi));
    Y = round(idct(Wi));
    prederr_r = Y;

    rebuild_loop = pred + prederr_r;

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

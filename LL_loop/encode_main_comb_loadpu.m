function [Seq_r, bits_frame, mode_all, cnt_blk, cnt_loop, bits_blk_all, bits_loop_all] = encode_main_comb()
    load('F:/NewCodec/LL_loop/chinaspeed_ll_src_pu.mat');
    initGlobals(100);
    Seq = double(srcy);

    global h w
    [h, w] = size(Seq);

    [bits_frame, mode_all, Seq_r_ex, cnt_blk, cnt_loop, bits_blk_all, bits_loop_all] = intra_16(Seq, pu_order);
    Seq_r = uint8(Seq_r_ex(1:h, 1:w));
end

function [bits_frame, mode_all, Seq_r, cnt_blk, cnt_loop, bits_blk_all, bits_loop_all] = intra_16(Seq, pu_order)
    global h w
    mode_frame = nan(h, w);
    bits_frame = 0;
    mode_all = {};
    Seq_r = nan(h + 64, w + 64);
    [blk_sum, ~] = size(pu_order);
    cnt_blk = 0;
    cnt_loop = 0;

    for blk_ind = 1:blk_sum
        PU = pu_order(blk_ind, 3);
        j = pu_order(blk_ind, 1) + 1;
        i = pu_order(blk_ind, 2) + 1;
        %%%%%%%%%%%%%%% block 部分
        [prederr_blk, ~, ~, mode_blk] = mode_select_blk(Seq, Seq_r, i, j, PU);
        bits_blk = code_block(prederr_blk);

        mode_frame = Mode_All(mode_frame, i, j, PU, mode_blk);
        [flag, Y, ~] = Mode1(0, mode_frame, i, j);
        if flag
            bits_blk = bits_blk + 1 + 2;
        else
            bits_blk = bits_blk + 1 + 5;
        end
        %%%%%%%%%%%%%%% block 部分

        %%%%%%%%%%%%%% loop 部分
        % prederr_cq_loop_all = nan(16, 31);
        for k = PU:-1:1
            [prederr_loop, pred_loop, ~, mode_loop] = mode_select_loop(Seq, Seq_r, i, j, k, PU);

            [Seq_r] = get_rebuild_loop(prederr_loop, pred_loop, i, j, k, PU, Seq_r);
            prederr_loop_all(PU - k + 1, 1:2 * k - 1) = prederr_loop;
            mode_all_loop(PU + 1 - k) = mode_loop;

            % cnt = PU - k;
            % prederr_blk_loop(1 + cnt, 1 + cnt) = prederr_loop(k);
            % dctq_blk_loop(1 + cnt, 1 + cnt) = prederr_cq_loop(k);
            % if (k ~= 1)
            %     prederr_blk_loop(1 + cnt, 2 + cnt:16) = prederr_loop(k + 1:end);
            %     prederr_blk_loop(2 + cnt:16, 1 + cnt) = prederr_loop(k - 1:-1:1);
            %     dctq_blk_loop(1 + cnt, 2 + cnt:16) = prederr_cq_loop(k + 1:end);
            %     dctq_blk_loop(2 + cnt:16, 1 + cnt) = prederr_cq_loop(k - 1:-1:1);
            % end
        end
        bits_loop = encode_prederr_loop(prederr_loop_all);
        bits_loop = bits_loop + huffman(diff([mode_all_loop(1), mode_all_loop(1:end-2)]));
        %%%%%%%%%%%%%% loop 部分

        if (bits_blk <= bits_loop)
            bits_frame = bits_frame + bits_blk;
            mode_all{blk_ind} = mode_blk;
            cnt_blk = cnt_blk + 1;
            bits_blk_all(blk_ind) = bits_blk;
        else
            bits_frame = bits_frame + bits_loop;
            mode_all{blk_ind} = mode_all_loop;
            cnt_loop = cnt_loop + 1;
            bits_loop_all(cnt_loop) = bits_loop;
        end
    end
    Seq_r(i:i + PU - 1, j:j + PU - 1) = Seq(i:i + PU - 1, j:j + PU - 1);
end

function [bits_mb] = code_block(err)
    bits_mb = huffman(err);
end

function [prederr, pred, sae, mode] = mode_select_blk(Seq, Seq_r, i, j, PU)
    dst = Seq(i:i + PU - 1, j:j + PU - 1);
    if (i == 1 || j == 1)
        lt = nan;
    else
        lt = Seq_r(i - 1, j - 1);
    end
    if (j == 1)
        left = nan(2 * PU, 1);
    else
        left = Seq_r(i:i + 2 * PU - 1, j - 1);
    end
    if (i == 1)
        top = nan(1, 2 * PU);
    else
        top = Seq_r(i - 1, j:j + 2 * PU - 1);
    end
    [PX, PY] = fill_ref_nan(left, top, lt, PU);
    % Intra DC Prediction
    Intra_DC = DC_Model(PU, PX, PY);
    % Intra Planar Prediction
    Intra_Planar = Planar_Model(PU, PX, PY);
    % Intra Angular Prediction
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

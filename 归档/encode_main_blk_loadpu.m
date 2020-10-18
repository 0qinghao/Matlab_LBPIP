function [Seq_r_blk, bits_frame_blk, mode_all_blk, cnt_blk, prederr_all_blk, bits_all_blk] = encode_main_blk()
    load('F:/NewCodec/LL_loop/chinaspeed_ll_src_pu.mat');
    initGlobals(100);
    Seq = double(srcy);

    global h w
    [h, w] = size(Seq);

    [mode_all_blk, Seq_r_ex, cnt_blk, prederr_all_blk, bits_all_blk] = intra_16(Seq, pu_order);
    bits_frame_blk = sum(bits_all_blk);
    Seq_r_blk = uint8(Seq_r_ex(1:h, 1:w));
end

function [mode_all, Seq_r, cnt_blk, prederr_all, bits_all_blk] = intra_16(Seq, pu_order)
    global h w
    mode_all = [];
    mode_frame = nan(h, w);
    Seq_r = nan(h + 64, w + 64);
    [blk_sum, ~] = size(pu_order);
    cnt_blk = blk_sum;

    for blk_ind = 1:blk_sum
        %%%%%%%%%%%%%%% block 部分
        Seq_r_blk = Seq_r;
        j = pu_order(blk_ind, 1) + 1;
        i = pu_order(blk_ind, 2) + 1;
        PU = pu_order(blk_ind, 3);
        [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(Seq, Seq_r_blk, i, j, PU);

        [bits_blk] = code_block(prederr_blk);
        Seq_r(i:i + PU - 1, j:j + PU - 1) = prederr_blk + pred_blk;
        %%%%%%%%%%%%%%% block 部分
        prederr_all{blk_ind} = prederr_blk;
        mode_all(blk_ind) = mode_blk;
        bits_all_blk(blk_ind) = bits_blk;

        mode_frame = Mode_All(mode_frame, i, j, PU, mode_blk);
        [flag, Y, ~] = Mode1(0, mode_frame, i, j);
        if flag
            bits_all_blk(blk_ind) = bits_all_blk(blk_ind) + 1 + 2;
        else
            bits_all_blk(blk_ind) = bits_all_blk(blk_ind) + 1 + 5;
        end
    end
end

function [bits_mb] = code_block(err)
    bits_mb = huffman(err);
end

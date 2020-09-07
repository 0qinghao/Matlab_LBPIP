function [Seq_r, bits_frame, mode_all, icp_all_block, err_all_block, dctq_all_block] = encode_main_block(Seq, Quant)
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
    cnt = 1;
    Seq_r = nan(h, w);
    Seq_r(1, :) = 128;
    Seq_r(:, 1) = 128;

    for i = 2:16:h - 32
        for j = 2:16:w - 32
            [icp, pred, ~, mode] = mode_select_16(Seq, Seq_r, i, j);

            [icp_r, bits, dctq] = code_block_16x16(icp);
            bits_frame = bits_frame + bits;
            Seq_r(i:i + 15, j:j + 15) = icp_r + pred;
            % total_sae = total_sae + sae;
            mode_all(cnt) = mode;
            icp_all_block{cnt} = icp;
            err_all_block{cnt} = Seq_r(i:i + 15, j:j + 15) - Seq(i:i + 15, j:j + 15);
            dctq_all_block{cnt} = dctq;
            cnt = cnt + 1;
        end
    end
end
%--------------------------------------------------------
%% Transform, Quantization, Entropy coding
% transform = Integer transform
% Quantization = h.264
% VLC = CAVLC (H.264)

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

function [icp, pred, sae, mode] = mode_select_16(Seq, Seq_r, i, j)
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

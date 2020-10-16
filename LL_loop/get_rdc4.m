function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc4(x, y, img_src, img_rebuild, split_frame, mode_frame)
    PU = 4; %4 8 16 32 64

    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    img_rebuild(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    mode_frame = Mode_All(mode_frame, x, y, PU, mode_blk);

    [flag, ~, ~] = Mode1(0, mode_frame, x, y);
    if flag
        mode_bits = 3;
    else
        mode_bits = 6;
    end

    rdc = cal_rdc_blk(prederr_blk, mode_blk, mode_bits);

    split_frame(x:x + PU - 1, y:y + PU - 1) = 4;
end

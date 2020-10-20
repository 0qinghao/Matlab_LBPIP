function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc8(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_deep_layer, rdc_ind)
    PU = 8; %4 8 16 32 64

    [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = prederr_blk + pred_blk;
    mode_frame_temp = Mode_All(mode_frame, x, y, PU, mode_blk);

    [flag, Y, ~] = Mode1(0, mode_frame_temp, x, y);
    if flag
        mode_bits = 3;
    else
        mode_bits = 6;
    end

    rdc_curr = cal_rdc_blk(prederr_blk, mode_blk, mode_bits);
    rdc_deep = sum(rdc_deep_layer(rdc_ind * 4 - 3:rdc_ind * 4));

    if (rdc_curr < rdc_deep)
        rdc = rdc_curr;
        mode_frame = mode_frame_temp;
        split_frame = Mode_All(split_frame, x, y, PU, PU);
    else
        rdc = rdc_deep;
        % mode_frame 保持不变
        % split_frame 保持不变
    end
end

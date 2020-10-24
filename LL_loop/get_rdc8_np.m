function [img_rebuild, split_frame, mode_frame, rdc] = get_rdc8_np(x, y, img_src, img_rebuild, split_frame, mode_frame, rdc_deep_layer, rdc_ind)
    PU = 8; %4 8 16 32 64
    mask_mat = [1111, 0111, 1011, 1101, 1110];

    % loop 部分
    [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop_np(img_src, img_rebuild, x, y, PU);
    % img_rebuild_temp_loop = prederr_blk_loop + pred_blk_loop;
    mode_frame_temp_loop = fill_blk_np(mode_frame, x, y, PU, mode_blk_loop);
    mode_bits_loop = cal_loop_mode_bits_np(mode_blk_loop, mode_frame_temp_loop, x, y);
    rdc_curr_temp_loop = cal_rdc_np(prederr_blk_loop, mode_bits_loop);
    % loop 部分

    % blk 部分
    rdc_curr_temp_blk_m = nan(1, 5);
    for i = 1:5
        mask = mask_mat(i);
        pred_range = get_pred_range(PU, mask);
        [prederr_blk_m{i}, pred_blk_m{i}, ~, mode_blk_m{i}] = mode_select_blk_np(img_src, img_rebuild, x, y, PU, pred_range);
        % img_rebuild_temp_blk = prederr_blk + pred_blk;
        mode_frame_temp_blk_m{i} = fill_blk_np(mode_frame, x, y, PU, mode_blk_m{i});
        mode_bits = get_mode_bits_blk_np(0, mode_frame_temp_blk_m{i}, x, y);
        rdc_curr_temp_blk_m(i) = cal_rdc_np(prederr_blk_m{i}, mode_bits, pred_range, rdc_deep_layer, rdc_ind, mask);
    end
    [rdc_curr_temp_blk, mask_blk_ind] = min(rdc_curr_temp_blk_m);
    mode_frame_temp_blk = mode_frame_temp_blk_m{mask_blk_ind};
    % blk 部分

    rdc_deep = sum(rdc_deep_layer(rdc_ind * 4 - 3:rdc_ind * 4));
    if (min(rdc_curr_temp_blk, rdc_curr_temp_loop) <= rdc_deep)
        if (rdc_curr_temp_loop < rdc_curr_temp_blk)
            rdc = rdc_curr_temp_loop;
            mode_frame = mode_frame_temp_loop;
        else
            rdc = rdc_curr_temp_blk;
            mode_frame = mode_frame_temp_blk;
        end
        split_frame = Mode_All(split_frame, x, y, PU, PU);
    else
        rdc = rdc_deep;
        % mode_frame 保持不变
        % split_frame 保持不变
    end
    %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
    % img_rebuild_temp(x:x + PU - 1, y:y + PU - 1) = img_rebuild_temp_blk;
end

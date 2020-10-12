function [split_frame, mode_frame, rdc] = get_rdc16_comb(CTU, img_src, img_rebuild, split_frame, mode_frame, rdc_8)
    img_rebuild_temp = img_rebuild;
    PU = 16; %4 8 16 32 64
    PU_num = 16; %256 64 16 4 1
    find_step = 16; %1 4 16 64 256
    global zorder;

    x = zeros(1, PU_num);
    y = zeros(1, PU_num);
    for i = 1:find_step:256
        ii = (i - 1) / find_step + 1;
        [x(ii), y(ii)] = find(zorder == i - 1, 1);
    end
    x = (x - 1) * 4 + CTU.x;
    y = (y - 1) * 4 + CTU.y;

    for i = 1:PU_num
        % loop 部分
        mode_frame_temp = mode_frame;
        [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop(img_src, img_rebuild_temp, x(i), y(i), PU);
        % img_rebuild_temp(x(i):x(i) + PU - 1, y(i):y(i) + PU - 1) = prederr_blk_loop + pred_blk_loop;
        img_rebuild_temp_loop = prederr_blk_loop + pred_blk_loop;
        mode_frame_temp_loop = Mode_All(mode_frame_temp, x(i), y(i), PU, mode_blk_loop);
        mode_bits_loop = cal_loop_mode_bits(mode_blk_loop, mode_frame_temp_loop, x(i), y(i));
        rdc_curr_temp_loop = cal_rdc(prederr_blk_loop, mode_bits_loop);
        % loop 部分
        % blk 部分
        mode_frame_temp = mode_frame;
        [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild_temp, x(i), y(i), PU);
        % img_rebuild_temp(x(i):x(i) + PU - 1, y(i):y(i) + PU - 1) = prederr_blk + pred_blk;
        img_rebuild_temp_blk = prederr_blk + pred_blk;
        mode_frame_temp_blk = Mode_All(mode_frame_temp, x(i), y(i), PU, mode_blk);
        [flag, Y, ~] = Mode1(0, mode_frame_temp_blk, x(i), y(i));
        if flag
            mode_bits = 3;
        else
            mode_bits = 6;
        end
        rdc_curr_temp_blk = cal_rdc(prederr_blk, mode_bits);
        % blk 部分

        % mode_log(i) = mode_blk;
        rdc_deep = sum(rdc_8((i - 1) * 4 + 1:(i - 1) * 4 + 4));
        if (min(rdc_curr_temp_blk, rdc_curr_temp_loop) <= rdc_deep)
            if (rdc_curr_temp_loop <= rdc_curr_temp_blk)
                rdc(i) = rdc_curr_temp_loop;
                mode_frame = Mode_All(mode_frame, x(i), y(i), PU, mode_blk_loop);
            else
                rdc(i) = rdc_curr_temp_blk;
                mode_frame = Mode_All(mode_frame, x(i), y(i), PU, mode_blk);
            end
            split_frame = Mode_All(split_frame, x(i), y(i), PU, PU);
        else
            rdc(i) = rdc_deep;
            % mode_frame 保持不变
            % split_frame 保持不变
        end
        %assert(all(img_rebuild_temp_blk == img_rebuild_temp_loop, [1, 2]))
        img_rebuild_temp(x(i):x(i) + PU - 1, y(i):y(i) + PU - 1) = img_rebuild_temp_blk;
    end
end

function [spilt_frame, mode_frame, rdc, img_rebuild_temp] = get_rdc64_loop(CTU, img_src, img_rebuild, spilt_frame, mode_frame, rdc_32)
    img_rebuild_temp = img_rebuild;
    PU = 64; %4 8 16 32 64
    PU_num = 1; %256 64 16 4 1
    find_step = 256; %1 4 16 64 256
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
        mode_frame_temp = mode_frame;
        [prederr_blk_loop, pred_blk_loop, mode_blk_loop] = mode_select_loop(img_src, img_rebuild_temp, x(i), y(i), PU);
        img_rebuild_temp(x(i):x(i) + PU - 1, y(i):y(i) + PU - 1) = prederr_blk_loop + pred_blk_loop;
        mode_frame_temp = Mode_All(mode_frame_temp, x(i), y(i), PU, mode_blk_loop);
        mode_bits_loop = cal_loop_mode_bits(mode_blk_loop);
        rdc_curr(i) = cal_rdc(prederr_blk_loop, mode_bits_loop);
        % mode_log(i) = mode_blk;
        rdc_deep = sum(rdc_32((i - 1) * 4 + 1:(i - 1) * 4 + 4));
        if (rdc_curr(i) <= rdc_deep)
            rdc(i) = rdc_curr(i);
            mode_frame = Mode_All(mode_frame, x(i), y(i), PU, mode_blk_loop);
            spilt_frame = Mode_All(spilt_frame, x(i), y(i), PU, PU);
        else
            rdc(i) = rdc_deep;
            % mode_frame 保持不变
            % spilt_frame 保持不变
        end
    end
end

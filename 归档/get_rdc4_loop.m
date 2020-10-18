function [split_frame, mode_frame, rdc] = get_rdc4_loop(CTU, img_src, img_rebuild, split_frame, mode_frame)
    PU = 4; %4 8 16 32 64
    PU_num = 256; %256 64 16 4 1
    find_step = 1; %1 4 16 64 256
    global zorder;
    mode_frame_temp = mode_frame;
    img_rebuild_temp = img_rebuild;

    x = zeros(1, PU_num);
    y = zeros(1, PU_num);
    for i = 1:find_step:256
        [x(i), y(i)] = find(zorder == i - 1, 1);
    end
    x = (x - 1) * 4 + CTU.x;
    y = (y - 1) * 4 + CTU.y;

    for i = 1:PU_num
        [prederr_blk, pred_blk, ~, mode_blk] = mode_select_blk(img_src, img_rebuild_temp, x(i), y(i), PU);
        img_rebuild_temp(x(i):x(i) + PU - 1, y(i):y(i) + PU - 1) = prederr_blk + pred_blk;
        mode_frame_temp = Mode_All(mode_frame_temp, x(i), y(i), PU, mode_blk);
        [flag, Y, ~] = Mode1(0, mode_frame_temp, x(i), y(i));
        if flag
            mode_bits = 3;
        else
            mode_bits = 6;
        end
        rdc(i) = cal_rdc(prederr_blk, mode_bits);
        % mode_log(i) = mode_blk;
    end

    mode_frame = mode_frame_temp;
    split_frame(CTU.x:CTU.x + 63, CTU.y:CTU.y + 63) = 4;
end

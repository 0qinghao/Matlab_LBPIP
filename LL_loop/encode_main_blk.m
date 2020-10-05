function [size_all, blk_size_sum, spilt_frame, mode_frame, CTU_bits] = encode_main_blk()
    initGlobals(100);
    global zorder;
    zorder = gen_zorder_mat();

    [CTU, img_src] = spilt_CTU();
    global h w
    img_rebuild = nan(h + 64, w + 64);
    spilt_frame = nan(h, w);
    mode_frame = nan(h, w);

    % for i = 1:numel(CTU)
    for i = 1:2
        [CTU_bits(i), img_rebuild, spilt_frame, mode_frame] = encode_CTU(CTU(i), img_src, img_rebuild, spilt_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, spilt_frame, mode_frame);
end

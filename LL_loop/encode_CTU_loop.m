function [CTU_bits, img_rebuild, split_frame, mode_frame] = encode_CTU_loop(CTU, img_src, img_rebuild, split_frame, mode_frame)

    [split_frame_4, mode_frame_4, rdc_4] = get_rdc4_loop(CTU, img_src, img_rebuild, split_frame, mode_frame);
    [split_frame_8, mode_frame_8, rdc_8] = get_rdc8_loop(CTU, img_src, img_rebuild, split_frame_4, mode_frame_4, rdc_4);
    [split_frame_16, mode_frame_16, rdc_16] = get_rdc16_loop(CTU, img_src, img_rebuild, split_frame_8, mode_frame_8, rdc_8);
    [split_frame_32, mode_frame_32, rdc_32] = get_rdc32_loop(CTU, img_src, img_rebuild, split_frame_16, mode_frame_16, rdc_16);
    [split_frame_64, mode_frame_64, rdc_64, img_rebuild_64] = get_rdc64_loop(CTU, img_src, img_rebuild, split_frame_32, mode_frame_32, rdc_32);

    CTU_bits = rdc_64;
    split_frame = split_frame_64;
    img_rebuild = img_rebuild_64;
    mode_frame = mode_frame_64;

end

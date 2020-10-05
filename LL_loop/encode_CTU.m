function [CTU_bits, img_rebuild, spilt_frame, mode_frame] = encode_CTU(CTU, img_src, img_rebuild, spilt_frame, mode_frame)

    [spilt_frame_4, mode_frame_4, rdc_4] = get_rdc4(CTU, img_src, img_rebuild, spilt_frame, mode_frame);
    [spilt_frame_8, mode_frame_8, rdc_8] = get_rdc8(CTU, img_src, img_rebuild, spilt_frame_4, mode_frame_4, rdc_4);
    [spilt_frame_16, mode_frame_16, rdc_16] = get_rdc16(CTU, img_src, img_rebuild, spilt_frame_8, mode_frame_8, rdc_8);
    [spilt_frame_32, mode_frame_32, rdc_32] = get_rdc32(CTU, img_src, img_rebuild, spilt_frame_16, mode_frame_16, rdc_16);
    [spilt_frame_64, mode_frame_64, rdc_64, img_rebuild_64] = get_rdc64(CTU, img_src, img_rebuild, spilt_frame_32, mode_frame_32, rdc_32);

    CTU_bits = rdc_64;
    spilt_frame = spilt_frame_64;
    img_rebuild = img_rebuild_64;
    mode_frame = mode_frame_64;

end

function [size_all, blk_size_sum, split_frame, mode_frame, CTU_bits] = encode_main_np_blk(srcy)
    initGlobals(100);

    [CTU, img_src] = split_CTU(srcy);
    [h, w] = size(srcy);
    img_rebuild = nan(h + 64, w + 64);
    split_frame = nan(h, w);
    mode_frame = nan(h, w);

    for i = 1:numel(CTU)
        % for i = 1:3
        i
        [CTU_bits(i), img_rebuild, split_frame, mode_frame] = encode_CTU_np_blk(CTU(i), img_src, img_rebuild, split_frame, mode_frame);
    end

    [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame);
end

function [size_all, blk_size_sum] = summary(CTU_bits, split_frame, mode_frame)

    size_all = sum(CTU_bits);

    cnt4 = sum((split_frame == 4), [1, 2]) / 16;
    cnt8 = sum((split_frame == 8), [1, 2]) / 64;
    cnt16 = sum((split_frame == 16), [1, 2]) / (16 * 16);
    cnt32 = sum((split_frame == 32), [1, 2]) / (32 * 32);
    cnt64 = sum((split_frame == 64), [1, 2]) / (64 * 64);

    blk_size_sum = [cnt4, cnt8, cnt16, cnt32, cnt64];
end

function [PSNR, snr] = psnruint(src, dst)
    src = uint8(src);
    dst = uint8(dst);

    [PSNR, snr] = psnr(src, dst);
end

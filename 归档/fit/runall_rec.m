piclist = {
        'bar.ppm';
        'kitchen.ppm';
% 'building1072.ppm';
% 'character.ppm';
% 'earth1072.ppm';
% 'flower.ppm';
% 'pcgame.ppm';
% 'pc_desktop.ppm';
% 'shop.ppm';
% 'street.ppm';
% 'wedding.ppm';
        };
jpeg_q = 90;
headsize = 607;
L = 4;
U = 12;
parfor picnum = 1:length(piclist)
    src = imread(piclist{picnum});
    peaksnr = zeros(1, U - L + 1);
    snrval = peaksnr;
    ssimval = peaksnr;
    filesize_KByts = peaksnr;
    MOSpsnr = peaksnr;
    MOSssim = peaksnr;
    filenamestr = cell(1, U - L + 1);

    for i = L:U
        main(piclist{picnum}, jpeg_q, i);

        file_base = dir(strcat(strrep(piclist{picnum}, '.ppm', ''), '_base_', int2str(jpeg_q), '_', int2str(i), '.jpg'));
        file_fix1 = dir(strcat(strrep(piclist{picnum}, '.ppm', ''), '_fixval_', int2str(jpeg_q), '_', int2str(i), '.ecs1'));
        file_fix2 = dir(strcat(strrep(piclist{picnum}, '.ppm', ''), '_fixval_', int2str(jpeg_q), '_', int2str(i), '.ecs2'));
        file_rebuild = dir(strcat(strrep(piclist{picnum}, '.ppm', ''), '_rebuild_', int2str(jpeg_q), '_', int2str(i), '.ppm'));
        filenamestr(i - L + 1) = {file_rebuild.name};
        dst = imread(file_rebuild.name);
        [peaksnr(i - L + 1), snrval(i - L + 1)] = psnr(src, dst)
        [ssimval(i - L + 1), ~] = ssim(src, dst);
        filesize_KByts(i - L + 1) = (file_base.bytes - headsize + file_fix1.bytes + file_fix2.bytes) / 1024;
        MOSpsnr(i - L + 1) = -24.3816 * (0.5 - 1 ./ (1 + exp(-0.56962 * (peaksnr(i - L + 1) - 27.49855)))) + 1.9663 * peaksnr(i - L + 1) - 2.37071;
        MOSssim(i - L + 1) = 2062.3 * (1 / (1 + exp(-11.8 * (ssimval(i - L + 1) - 1.3))) + 0.5) + 40.6 * ssimval(i - L + 1) - 1035.6;
    end
    compress_ratio = 1 ./ (filesize_KByts * 1024 / (1920 * 1080 * 3));
    tabletitle = {'filename', 'size_KB', 'compress_ratio', 'SNR', 'PSNR', 'SSIM', 'PSNR2MOS', 'SSIM2MOS'};
    csvdata = table(filenamestr(:), filesize_KByts(:), compress_ratio(:), snrval(:), peaksnr(:), ssimval(:), MOSpsnr(:), MOSssim(:), 'VariableNames', tabletitle);
    writetable(csvdata, ['rec_', piclist{picnum}, '_evaluation.csv']);
end

recycle('on');
% delete('*.ppm.jpg')

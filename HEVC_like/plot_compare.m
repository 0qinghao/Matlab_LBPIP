function plot_compare(picName)
    %    工作簿: F:\NewCodec\log.xlsm
    %    工作表: JPEG结果
    opts = spreadsheetImportOptions("NumVariables", 10);
    opts.Sheet = "JPEG结果";
    opts.DataRange = "A2:J337";
    opts.VariableNames = ["filename", "size_KB", "compress_ratio", "SNR", "PSNR", "SSIM", "PSNR2MOS", "SSIM2MOS", "src_file", "algorithm"];
    opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical"];
    % 指定变量属性
    opts = setvaropts(opts, "filename", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["filename", "src_file", "algorithm"], "EmptyFieldRule", "auto");
    % 导入数据
    log_jpeg = readtable("F:\NewCodec\log.xlsm", opts, "UseExcel", false);
    %% 清除临时变量
    clear opts
    %    工作簿: F:\NewCodec\log.xlsm
    %    工作表: HEVC结果
    opts = spreadsheetImportOptions("NumVariables", 10);
    opts.Sheet = "HEVC结果";
    opts.DataRange = "A2:J337";
    opts.VariableNames = ["filename", "size_KB", "compress_ratio", "SNR", "PSNR", "SSIM", "PSNR2MOS", "SSIM2MOS", "src_file", "algorithm"];
    opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical"];
    % 指定变量属性
    opts = setvaropts(opts, "filename", "WhitespaceRule", "preserve");
    opts = setvaropts(opts, ["filename", "src_file", "algorithm"], "EmptyFieldRule", "auto");
    % 导入数据
    log_hevc = readtable("F:\NewCodec\log.xlsm", opts, "UseExcel", false);
    %% 清除临时变量
    clear opts
    % %    工作簿: F:\NewCodec\log.xlsm
    % %    工作表: NEW结果
    % opts = spreadsheetImportOptions("NumVariables", 10);
    % opts.Sheet = "NEW结果";
    % opts.DataRange = "A2:J337";
    % opts.VariableNames = ["filename", "size_KB", "compress_ratio", "SNR", "PSNR", "SSIM", "PSNR2MOS", "SSIM2MOS", "src_file", "algorithm"];
    % opts.VariableTypes = ["string", "double", "double", "double", "double", "double", "double", "double", "categorical", "categorical"];
    % % 指定变量属性
    % opts = setvaropts(opts, "filename", "WhitespaceRule", "preserve");
    % opts = setvaropts(opts, ["filename", "src_file", "algorithm"], "EmptyFieldRule", "auto");
    % % 导入数据
    % log_hevc = readtable("F:\NewCodec\log.xlsm", opts, "UseExcel", false);
    % %% 清除临时变量
    % clear opts

    hevc_temp = table2array(log_hevc(log_hevc.src_file == picName, {'PSNR', 'compress_ratio'})); psnr_hevc = hevc_temp(:, 1); ratio_hevc = hevc_temp(:, 2);
    jpeg_temp = table2array(log_jpeg(log_jpeg.src_file == picName, {'PSNR', 'compress_ratio'})); psnr_jpeg = jpeg_temp(:, 1); ratio_jpeg = jpeg_temp(:, 2);
    % new_temp = table2array(log_new(log_new.src_file == picName, {'PSNR', 'compress_ratio'})); psnr_new = new_temp(:, 1); ratio_new = new_temp(:, 2);

    handle = plot(psnr_jpeg, ratio_jpeg, '-go', psnr_hevc, ratio_hevc, '-r*');
    grid on
%     title([picName, ' 压缩倍率-PSNR'])
title([' 压缩倍率-PSNR'])
    xlabel('PSNR')
    ylabel('压缩倍率')
    legend('关键像素+迭代预测', 'HEVC-inner')
    % legend('JPEG', 'HEVC-inner', 'New')
    xt = xticks; xticks(xt(1):xt(end))
    yt = yticks; yticks(yt(1):4:yt(end))
end

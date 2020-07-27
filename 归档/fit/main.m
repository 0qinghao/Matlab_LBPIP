% function [PSNR] = main(inputName, quality, Q_fix)
function [PSNR] = main(inputName, quality, TH_fix, TH_div)
    % inputName = 'flower.ppm';
    % inputName = 'bar.ppm';
    % quality = 90;
    % inputName = 'kitchen.ppm';
    % quality = 90;

    % picName = strrep(inputName, '.ppm', '');
    % baseName = strcat(picName, '_base_', int2str(quality), '_', int2str(Q_fix), '.jpg');
    % fixvalName = strcat(picName, '_fixval_', int2str(quality), '_', int2str(Q_fix), '.ecs');
    % modeName = strcat(picName, '_mode_', int2str(quality), '_', int2str(Q_fix), '.ecs');
    % outputName = strcat(picName, '_rebuild_', int2str(quality), '_', int2str(Q_fix), '.ppm');
    picName = strrep(inputName, '.ppm', '');
    baseName = strcat(picName, '_base_', int2str(quality), '_', int2str(TH_fix), '.jpg');
    fixvalName = strcat(picName, '_fixval_', int2str(quality), '_', int2str(TH_fix), '.ecs');
    modeName = strcat(picName, '_mode_', int2str(quality), '_', int2str(TH_fix), '.ecs');
    outputName = strcat(picName, '_rebuild_', int2str(quality), '_', int2str(TH_fix), '.ppm');

    % [PSNR] = code_rec(inputName, baseName, fixvalName, modeName, outputName, Q_fix)
    % [PSNR] = code_rec(inputName, baseName, fixvalName, modeName, outputName, TH_fix, TH_div)
    [PSNR] = code_basekey(inputName, baseName, fixvalName, modeName, outputName, TH_fix, TH_div, quality)

end

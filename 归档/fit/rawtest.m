% 33 dB 绝望

SIZE = 6;
load('./dnxy.mat');
inputName = './kitchen.ppm';
rgb = imread(inputName);
yuv = jpeg_rgb2ycbcr(rgb);
yuv = double(yuv);

[yuv_cell, repeat_height, repeat_width] = img_mat2cell(yuv, SIZE);
rebuild = yuv_cell;

for i = 1:repeat_height
    for j = i:repeat_width
        for k = 1:3
            mat = yuv_cell{i, j}(:, :, k);
            p1 = mat(1, 1);
            p2 = mat(SIZE, 1);
            p3 = mat(1, SIZE);
            p4 = mat(SIZE, SIZE);

            pd1x = p1 ./ d1x;
            pd1y = p1 ./ d1y;
            pd2x = p2 ./ d2x;
            pd2y = p2 ./ d2y;
            pd3x = p3 ./ d3x;
            pd3y = p3 ./ d3y;
            p4dx = p4 ./ d4x;
            pd4x = p4 ./ d4x;
            pd4y = p4 ./ d4y;

            pd1xx = pd1x(:);
            pd2xx = pd2x(:);
            pd3xx = pd3x(:);
            pd4xx = pd4x(:);
            pd1yy = pd1y(:);
            pd2yy = pd2y(:);
            pd3yy = pd3y(:);
            pd4yy = pd4y(:);

            X = [ones(size(pd1xx)) pd1xx pd1yy pd2xx pd2yy pd3xx pd3yy pd4xx pd4yy];
            b = regress(mat(:), X);

            mat_fit = b(1) + b(2) * pd1xx + b(3) * pd1yy + b(4) * pd2xx + b(5) * pd2yy + b(6) * pd3xx + b(7) * pd3yy + b(8) * pd4xx + b(9) * pd4yy;

            rebuild{i, j}(:, :, k) = reshape(mat_fit, SIZE, SIZE);
        end
    end
end

rebuild = uint8(cell2mat(rebuild));
imshow(rebuild);

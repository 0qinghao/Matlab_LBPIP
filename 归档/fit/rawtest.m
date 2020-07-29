% 33 dB 绝望

% load('./dnxy.mat')
inputName = './../../HEVC_like/earth.ppm';
rgb = imread(inputName);
yuv = jpeg_rgb2ycbcr(rgb);
yuv = double(yuv);
[yuv_cell, repeat_height, repeat_width] = img_mat2cell(yuv, 6);
rebuild = yuv_cell;

pre_ind = [1:7, 9:10, 12:25, 27:28, 30:36];
for i = 1:numel(pre_ind)
    [x, y] = ind2sub(6, pre_ind(i));

    d1(i) = sqrt((x - 2)^2 + (y - 2)^2);
    d2(i) = sqrt((x - 5)^2 + (y - 2)^2);
    d3(i) = sqrt((x - 2)^2 + (y - 5)^2);
    d4(i) = sqrt((x - 5)^2 + (y - 5)^2);
end

for i = 1:repeat_height
    for j = 1:repeat_width
        for k = 1:3
            mat = yuv_cell{i, j}(:, :, k);
            mat_p = mat(pre_ind);
            p1 = mat(2, 2);
            p2 = mat(5, 2);
            p3 = mat(2, 5);
            p4 = mat(5, 5);

            pd1 = p1 ./ d1;
            pd2 = p2 ./ d2;
            pd3 = p3 ./ d3;
            pd4 = p4 ./ d4;
            pd1 = pd1(:);
            pd2 = pd2(:);
            pd3 = pd3(:);
            pd4 = pd4(:);
            % pd1x = p1 ./ d1x;
            % pd1y = p1 ./ d1y;
            % pd2x = p2 ./ d2x;
            % pd2y = p2 ./ d2y;
            % pd3x = p3 ./ d3x;
            % pd3y = p3 ./ d3y;
            % p4dx = p4 ./ d4x;
            % pd4x = p4 ./ d4x;
            % pd4y = p4 ./ d4y;
            % pd1xx = pd1x(:);
            % pd2xx = pd2x(:);
            % pd3xx = pd3x(:);
            % pd4xx = pd4x(:);
            % pd1yy = pd1y(:);
            % pd2yy = pd2y(:);
            % pd3yy = pd3y(:);
            % pd4yy = pd4y(:);

            X = [ones(size(pd1)) pd1 pd2 pd3 pd4];
            b = regress(mat_p(:), X);

            mat_fit = b(1) + b(2) * pd1 + b(3) * pd2 + b(4) * pd3 + b(5) * pd4;

            rebuildmat = mat;
            rebuildmat(pre_ind) = mat_fit;
            rebuild{i, j}(:, :, k) = rebuildmat;
        end
    end
end

rebuild = jpeg_ycbcr2rgb(uint8(cell2mat(rebuild)));
imshow(rebuild);

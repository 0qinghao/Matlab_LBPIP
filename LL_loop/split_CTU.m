function [CTU, src_double] = split_CTU(srcy)
    % load('./basketballdrill_ll_srcy.mat', 'srcy');
    % load('./chinaspeed_ll_src_pu.mat', 'srcy');
    %     load('./traffic_ll_src_pu.mat', 'srcy');
    src = srcy;

    global h w
    [h, w] = size(src);

    cnt = 1;
    src_double = double(src);
    for i = 1:64:h
        for j = 1:64:w
            CTU(cnt).data = src_double(i:i + 63, j:j + 63);
            CTU(cnt).x = i;
            CTU(cnt).y = j;
            cnt = cnt + 1;
        end
    end
end

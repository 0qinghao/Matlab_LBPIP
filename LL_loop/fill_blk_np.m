function blk_all = fill_blk_np(blk_all, x, y, N, data, pred_range)
    %UNTITLED3 此处显示有关此函数的摘要
    %   此处显示详细说明
    % for i = a:a + N - 1
    %     for j = b:b + N - 1
    %         mode_all(i, j) = mode;
    %     end
    % end
    if numel(data) == 1
        data = repmat(data, N, N);
    end

    src = blk_all(x:x + N - 1, y:y + N - 1);
    data_masked = src;
    data_masked(pred_range) = data(pred_range);
    blk_all(x:x + N - 1, y:y + N - 1) = data_masked;
end

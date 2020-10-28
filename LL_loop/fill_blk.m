% 往 x,y 位置填 N*N 大小的 data
function blk_all = fill_blk(blk_all, x, y, N, data)
    % for i = a:a + N - 1
    %     for j = b:b + N - 1
    %         mode_all(i, j) = mode;
    %     end
    % end
    if numel(data) == 1
        data = repmat(data, N, N);
    end

    blk_all(x:x + N - 1, y:y + N - 1) = data;
end

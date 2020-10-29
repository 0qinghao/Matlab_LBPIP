% 左边一列 上面一行 参考像素存在还未重建的像素点时，进行填补（标准8.4.4.2.2节）
function [PX, PY] = fill_ref_nan(left, top, lt, PU)
    if (all(isnan([left(:); top(:); lt(:)])))
        PX = zeros(2 * PU + 1, 1) + 128;
        PY = PX';
        return
    end

    reverse = [top(end:-1:1), lt, left(1:end)'];
    if isnan(reverse(1))
        first_available = reverse(find(~isnan(reverse), 1));
        reverse(1) = first_available;
    end
    for i = 2:4 * PU + 1
        if isnan(reverse(i))
            reverse(i) = reverse(i - 1);
        end
    end
    PY = reverse(2 * PU + 1:-1:1);
    PX = reverse(2 * PU + 1:4 * PU + 1);

    % ref_2 = [top(end:-1:1), lt, left(1:end)'];

    % PY = [lt, top];
    % PY(isnan(PY)) = ref_2(find(~isnan(ref_2), 1));

    % ref_1 = [left(end:-1:1)', PY];
    % left(isnan(left)) = ref_1(find(~isnan(ref_1), 1));
    % PX = [PY(1); left];
end

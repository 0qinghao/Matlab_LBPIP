function cnt = get_code_cnt(data)
    global cnt_code;
    cnt_code = zeros(2,251);
    [repeat_height,repeat_width] = size(data);

    lastDC = 0;
    for i=1:repeat_height
        for j=1:repeat_width
            lastDC = huffman_forcnt(data{i, j}, lastDC(1), 1, 1);
        end
    end

    cnt = cnt_code';
end
function N = getlocationsizeorder(csvname)

    %产生关于z型扫描的顺序矩阵
    x = 1;
    y = 1;
    A = zeros(16, 16);
    for i = 0:3
        switch i
            case {1, 3}
                x = x + 1;
                y = y - 7;
            case 2
                x = x - 15;
                y = y + 1;
        end
        for j = 0:3
            switch j

                case {1, 3}
                    x = x + 1;
                    y = y - 3;
                case 2
                    x = x - 7;
                    y = y + 1;
            end
            for k = 0:3
                switch k
                    case {1, 3}
                        x = x + 1;
                        y = y - 1;
                    case 2
                        x = x - 3;
                        y = y + 1;
                end
                A(x, y) = k * 4 + j * 16 + i * 64;
                x = x + 1;
                A(x, y) = 1 + k * 4 + j * 16 + i * 64;
                x = x - 1; y = y + 1;
                A(x, y) = 2 + k * 4 + j * 16 + i * 64;
                x = x + 1;
                A(x, y) = 3 + k * 4 + j * 16 + i * 64;
            end
        end
    end

    % fin = fopen('str.bin_block_info_0.txt', 'r');
    fin = fopen(csvname, 'r', 'l');
    idx = 1;
    %最终结果存储在元胞数组pul中，每个元胞代表一个分割到最后的pu块，共包含3个数据，代表当前pu的坐标（先列后行）
    while ~feof(fin)
        str = fgetl(fin); %读取一行
        ctuno = regexp(str, '(?<=tu;)[0-9]+', 'match'); %由于第一行乱采取的措施
        if ~isempty(ctuno)
            no = str2double(ctuno);
        end
        ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %取出'ctu location;'后面的数字
        if ~isempty(ctutemp)
            ctu = strsplit(ctutemp{1}, 'x'); %分割开
            ctul = [str2double(ctu{1}) str2double(ctu{2})]; %从字符串转化为数字  这两个数字代表ctu实际坐标
        end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %取出pu rect;后面的数字
        if ~isempty(n)
            src = strsplit(n{1}, ','); %将数字分隔开
            pul{idx} = [str2double(src{1}) str2double(src{2}) str2double(src{3})]; %转化为数字存到pul的第一个元胞中
            %        a=str2double(src{1})/4+1;
            %        b=str2double(src{2})/4+1;
            order = A(str2double(src{1}) / 4 + 1, str2double(src{2}) / 4 + 1);
            order = order + no * 256;
            pul{idx}(1) = pul{idx}(1) + ctul(1); %pu rect后的前两个数字代表相对于当前ctu的相对坐标
            pul{idx}(2) = pul{idx}(2) + ctul(2); %所以实际坐标等于相对坐标＋ctu坐标
            pul{idx} = [pul{idx}(1), pul{idx}(2), pul{idx}(3), order];
            idx = idx + 1;
        end
    end
    M = cell2mat(pul');
    N = sortrows(M, 4); %根据扫描顺序排序后，按行的顺序。
    fclose(fin);

end

function [A, B] = getputunumber(csvname)
    fin = fopen(csvname, 'r', 'l');
    pnum4 = 0;
    pnum8 = 0;
    pnum16 = 0;
    pnum32 = 0;
    pnum64 = 0;
    tnum4 = 0;
    tnum8 = 0;
    tnum16 = 0;
    tnum32 = 0;
    tnum64 = 0;
    %最终结果存储在元胞数组pul中，每个元胞代表一个分割到最后的pu块，共包含3个数据，代表当前pu的坐标（先列后行）
    while ~feof(fin)
        str = fgetl(fin); %读取一行
        %    ctuno=regexp(str, '(?<=tu;)[0-9]+', 'match');%由于第一行乱采取的措施
        %    if ~isempty(ctuno)
        %       no=str2double(ctuno);
        %    end
        %    ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %取出'ctu location;'后面的数字
        %    if ~isempty(ctutemp)
        %        ctu = strsplit(ctutemp{1}, 'x'); %分割开
        %        ctul = [str2double(ctu{1}) str2double(ctu{2})]; %从字符串转化为数字  这两个数字代表ctu实际坐标
        %    end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %取出pu rect;后面的数字
        if ~isempty(n)
            src = strsplit(n{1}, ','); %将数字分隔开
            switch str2double(src{3})
                case 4
                    pnum4 = pnum4 + 1;
                case 8
                    pnum8 = pnum8 + 1;
                case 16
                    pnum16 = pnum16 + 1;
                case 32
                    pnum32 = pnum32 + 1;
                case 64
                    pnum64 = pnum64 + 1;
            end
        end
        m = regexp(str, '(?<=tu\ rect/qp;)([0-9]+,){2}[0-9]+', 'match'); %取出tu rect;后面的数字
        if ~isempty(m)
            srcm = strsplit(m{1}, ','); %将数字分隔开
            switch str2double(srcm{3})
                case 4
                    tnum4 = tnum4 + 1;
                case 8
                    tnum8 = tnum8 + 1;
                case 16
                    tnum16 = tnum16 + 1;
                case 32
                    tnum32 = tnum32 + 1;
                case 64
                    tnum64 = tnum64 + 1;
            end
        end
    end
    A = [pnum4, pnum8, pnum16, pnum32, pnum64];
    B = [tnum4, tnum8, tnum16, tnum32, tnum64];

    fclose(fin);
end

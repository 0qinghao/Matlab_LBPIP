function [pul] = getlocationsize(csvname)
    % fin=fopen('str.bin_block_info_0.txt','r');
    fin = fopen(csvname, 'r', 'l');
    idx = 1;
    %最终结果存储在元胞数组pul中，每个元胞代表一个分割到最后的pu块，共包含3个数据，代表当前pu的坐标（先列后行）
    while ~feof(fin)
        str = fgetl(fin); %读取一行
        ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %取出'ctu location;'后面的数字
        if ~isempty(ctutemp)
            ctu = strsplit(ctutemp{1}, 'x'); %分割开
            ctul = [str2double(ctu{1}) str2double(ctu{2})]; %从字符串转化为数字  这两个数字代表ctu实际坐标
        end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %取出pu rect;后面的数字
        if ~isempty(n)
            src = strsplit(n{1}, ','); %将数字分隔开
            pul{idx} = [str2double(src{1}) str2double(src{2}) str2double(src{3})]; %转化为数字存到pul的第一个元胞中
            pul{idx}(1) = pul{idx}(1) + ctul(1); %pu rect后的前两个数字代表相对于当前ctu的相对坐标
            pul{idx}(2) = pul{idx}(2) + ctul(2); %所以实际坐标等于相对坐标＋ctu坐标
            idx = idx + 1;
        end
    end
    fclose(fin);
end

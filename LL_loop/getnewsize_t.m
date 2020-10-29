function sum = getnewsize_t(mode_all, size_all, maxsize, ctux, ctuy)
    %     initGlobals(100);
    %     CTU =load('getnewsize_input_data.mat');
    %用来测试的数据
    %测试时假设一共9个CTU，当前CTU为正中间那个，起始坐标即为65,65
    %    maxsize=64;
    %    ctux=1;
    %    ctuy=1;
    %    mode_all=CTU.mode_all;
    %    size_all=CTU.size_all;
    %sizeall64=load('sizeall.mat');
    %modeall64=load('modeall.mat');
    %size_all64=sizeall64.sizeall;
    %mode_all64=modeall64.modeall;
    %mode_all=[mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64;mode_all64,mode_all64,mode_all64];
    mode_all64 = mode_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    size_all64 = size_all(ctux:ctux + maxsize - 1, ctuy:ctuy + maxsize - 1);
    idx = 0;
    c = 1;
    d = 1;
    sum = 0;
    temp = 0;

    %初步将矩阵中的数据转换为[行坐标，列坐标，块大小，0（存放标记非正方形块是哪个方向的信息）]的样子
    for i = 1:4:maxsize%这里的ij坐标须为当前点在当前CTU中的相对坐标
        for j = 1:4:maxsize
            if mod(size_all64(i, j), 2) == 0
                a = (floor(i / size_all64(i, j))) * size_all64(i, j) + 1;
                b = (floor(j / size_all64(i, j))) * size_all64(i, j) + 1;
            else
                sqwidth = (size_all64(i, j) - 1) * 2;
                a = floor(i / sqwidth) * sqwidth + 1; %(sizeall(i,j)-1)*2为非正方形补为正方形之后的宽度
                b = floor(j / sqwidth) * sqwidth + 1;
            end
            if (a ~= c || b ~= d) || (a == c && b == d && size_all64(i, j) ~= temp)
                idx = idx + 1;
            end

            L{idx} = [a, b, size_all64(i, j), 0];
            c = L{idx}(1);
            d = L{idx}(2);
            temp = L{idx}(3);
        end
    end
    %去除元胞数组中重复的元素项（这个是因为提取出来的信息因为一点小bug会有一部分重复）
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    %得到每个块的坐标，size信息
    %其中注意，所有非正方形块的定位坐标统一放在将其补齐为正方形后，左上角第一个点
    %包括左上角是块状预测的情况，这种情况下定位点不属于该非正方形块
    s = size(P);

    for k = 1:s(2)%先处理正方形块
        ai = P{k}(1) + ctux - 1; %在整帧中实际坐标
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) == 0
            cursq = mode_all64(P{k}(1):P{k}(1) + P{k}(3) - 1, P{k}(2):P{k}(2) + P{k}(3) - 1); %在当前CTU取出当前PU
            md = unique(cursq);
            if size(md) == 1%整个块只有一种模式说明是块状预测，先计算所有采用块状预测的块模式所占用比特数
                [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                % P{k}(5) = flag; %测试的时候检查用，可以不要

                if flag == 0%确认：flag=0表示在候选列表中，使用3bit
                    sum = sum + 3;
                else
                    sum = sum + 6; %不在则用6bit
                end
            else %方形块的环状预测
                modetemp = zeros(P{k}(3), 1);
                for l = 1:P{k}(3)
                    modetemp(l) = mode_all64(P{k}(1) + P{k}(3) - 1, l); %看最后一行即能得到所有模式号
                end
                %计算模式残差存入modediff
                modediff = zeros(P{k}(3), 1);
                if ai == 1
                    modediff(1) = modetemp(1) - 0;
                else
                    modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                end
                for x = 2:P{k}(3)
                    modediff(x) = modetemp(x) - modetemp(x - 1);
                end
                modediff = [modediff(1),diff(modetemp(1:P{k}(3)))];
                sum = sum + huffman_testsize(modediff);
            end
        end
    end
    %处理L型块
    for k = 1:s(2)
        ai = P{k}(1) + ctux - 1; %在整帧中实际坐标
        aj = P{k}(2) + ctuy - 1;
        if mod(P{k}(3), 2) ~= 0
            for y = 1:s(2)%通过能否找到对应位置的块坐标信息来判断属于哪种情况
                if y == k
                    continue;
                end
                if P{k}(1) == P{y}(1) && P{k}(2) == P{y}(2)%保留左上的情况
                    location = 1;
                elseif P{y}(1) == P{k}(1) && ...%保留右上的情况
                    P{y}(2) == P{k}(2) + size_all64(P{k}(1), P{k}(2)) - 1
                    location = 2;
                elseif P{y}(1) == P{k}(1) + size_all64(P{k}(1), P{k}(2)) - 1 && ...%保留左下的情况
                    P{y}(2) == P{k}(2)
                    location = 3;
                elseif P{y}(1) == P{k}(1) + size_all64(P{k}(1), P{k}(2)) - 1 && ...%保留右下的情况
                    P{y}(2) == P{k}(2) + size_all64(P{k}(1), P{k}(2)) - 1
                    location = 4;
                    % else
                    %     location=0;
                end
            end
            switch location
                case {1, 2}
                    modetemp = zeros((P{k}(3) - 1) * 2, 1);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all64(P{k}(1) + (P{k}(3) - 1) * 2 - 1, P{k}(2) + i - 1);
                    end
                    mdnum = size(unique(modetemp)); % 判断是否在整块中只有一种模式，若是则是使用块状预测
                    if mdnum(1) > 1%环状预测
                        modediff = zeros((P{k}(3) - 1) * 2, 1);
                        if ai == 1
                            modediff(1) = modetemp(1) - 0;
                        else
                            modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                        end
                        for x = 2:(P{k}(3) - 1) * 2
                            modediff(x) = modetemp(x) - modetemp(x - 1);
                        end
                        sum = sum + huffman_testsize(modediff);

                    else %说明是块状预测
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                        P{k}(5) = flag;
                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end

                case 3
                    modetemp = zeros((P{k}(3) - 1) * 2, 1);
                    modediff = zeros((P{k}(3) - 1) * 2, 1);
                    for i = 1:(P{k}(3) - 1) * 2
                        modetemp(i) = mode_all64(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end
                    mdnum = size(unique(modetemp));
                    if mdnum(1) > 1
                        if ai == 1
                            modediff(1) = modetemp(1) - 0;
                        else
                            modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                        end
                        for x = 2:(P{k}(3) - 1) * 2
                            modediff(x) = modetemp(x) - modetemp(x - 1);
                        end
                        sum = sum + huffman_testsize(modediff);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                        P{k}(5) = flag;
                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
                case 4
                    modetemp = zeros(P{k}(3) - 1, 1);
                    modediff = zeros(P{k}(3) - 1, 1);
                    for i = 1:P{k}(3) - 1
                        modetemp(i) = mode_all64(P{k}(1) + i - 1, P{k}(2) + i - 1);
                    end
                    mdnum = size(unique(modetemp));
                    if mdnum(1) > 1
                        if ai == 1
                            modediff(1) = modetemp(1) - 0;
                        else
                            modediff(1) = modetemp(1) - mode_all(ai - 1, aj);
                        end
                        for x = 2:P{k}(3) - 1
                            modediff(x) = modetemp(x) - modetemp(x - 1);
                        end
                        sum = sum + huffman_testsize(modediff);
                    else
                        [flag] = get_mode_bits_blk_flag(0, mode_all, ai, aj);
                        P{k}(5) = flag;
                        if flag == 0%确认：flag0表示在候选列表中
                            sum = sum + 3;
                        else
                            sum = sum + 6;
                        end
                    end
            end
        end
    end
end

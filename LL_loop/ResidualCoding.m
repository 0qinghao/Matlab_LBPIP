function Y = ResidualCoding(A, cIdx, IntraPredModeY, IntraPredModeC)
    %UNTITLED 此处显示有关此函数的摘要
    %   此处显示详细说明
    TrafoSize = size(A, 1);
    if ((TrafoSize == 4) || (TrafoSize == 8))
        if (cIdx == 0)
            predModeIntra = IntraPredModeY;
        else
            predModeIntra = IntraPredModeC;
        end
        if ((6 <= predModeIntra) && (predModeIntra <= 14))
            scanIdx = 2;
        elseif ((22 <= predModeIntra) && (predModeIntra <= 30))
            scanIdx = 1;
        else
            scanIdx = 0;
        end
    else
        scanIdx = 0;
    end
    r = size(A, 1);
    Y = zeros(1, r * r);
    k = 0;
    if (scanIdx == 0)
        for i = 1:r
            for j = 1:i
                k = k + 1;
                Y(k) = A(i - j + 1, j);
            end
        end
        for i = (r + 1):(2 * r - 1)
            for j = 1:(2 * r - i)
                k = k + 1;
                Y(k) = A(r - j + 1, i + j - r);
            end
        end
    elseif (scanIdx == 1)
        for i = 1:r
            for j = 1:r
                k = k + 1;
                Y(k) = A(i, j);
            end
        end
    elseif (scanIdx == 2)
        for i = 1:r
            for j = 1:r
                k = k + 1;
                Y(k) = A(j, i);
            end
        end
    else
    end
end

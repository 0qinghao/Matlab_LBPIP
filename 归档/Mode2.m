function [Y1, Y2, Z] = Mode2(D, mode_all, i, j)
    %UNTITLED 此处显示有关此函数的摘要
    %   此处显示详细说明
    if (i > 1 && j > 1)
        A = mode_all(i, j - 1);
        B = mode_all(i - 1, j);
        C = mode_all(i, j);
    else
        A = 0; B = 0; C = 0;
    end
    candModeList = [0, 0, 0];
    a = 0;
    if (A == B)
        if (A == 0 || A == 1)
            candModeList(1) = 0;
            candModeList(2) = 1;
            candModeList(3) = 26;
        elseif (A == 2)
            candModeList(1) = 2;
            candModeList(2) = 3;
            candModeList(3) = 33;
        elseif (A == 34)
            candModeList(1) = 34;
            candModeList(2) = 33;
            candModeList(3) = 3;
        else
            candModeList(1) = A;
            candModeList(2) = A - 1;
            candModeList(3) = A + 1;
        end
    else
        candModeList(1) = A;
        candModeList(2) = B;
        if (A ~= 0 && B ~= 0)
            candModeList(3) = 0;
        elseif (A ~= 1 && B ~= 1)
            candModeList(3) = 1;
        else
            candModeList(3) = 26;
        end
    end
    if (C == candModeList(1))
        Y1 = 0;
        Y2 = 0;
    elseif (C == candModeList(2))
        Y1 = 1;
        Y2 = 0;
    elseif (C == candModeList(3))
        Y1 = 2;
        Y2 = 0;
    else
        for i = 1:3
            if (C >= candModeList(i))
                a = a +1;
            end
        end
        C = C - a;
        Y1 = 3;
        Y2 = C;
    end
    switch C
        case 0
            switch D
                case 34
                    Z = 0;
                case 26
                    Z = 1;
                case 10
                    Z = 2;
                case 1
                    Z = 3;
                case 0
                    Z = 4;
                otherwise
                    Z = 7;
            end
        case 26
            switch D
                case 0
                    Z = 0;
                case 34
                    Z = 1;
                case 10
                    Z = 2;
                case 1
                    Z = 3;
                case 26
                    Z = 4;
                otherwise
                    Z = 7;
            end
        case 10
            switch D
                case 0
                    Z = 0;
                case 26
                    Z = 1;
                case 34
                    Z = 2;
                case 1
                    Z = 3;
                case 10
                    Z = 4;
                otherwise
                    Z = 7;
            end
        case 1
            switch D
                case 0
                    Z = 0;
                case 26
                    Z = 1;
                case 10
                    Z = 2;
                case 34
                    Z = 3;
                case 1
                    Z = 4;
                otherwise
                    Z = 7;
            end
        otherwise
            switch D
                case 0
                    Z = 0;
                case 26
                    Z = 1;
                case 10
                    Z = 2;
                case 1
                    Z = 3;
                case C
                    Z = 4;
                otherwise
                    Z = 7;
            end
    end
end

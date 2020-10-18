function sum = getbitlength_bak(A)
    %��������z��ɨ���˳�����
    x = 1;
    y = 1;
    C = zeros(16, 16);
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
                C(x, y) = k * 4 + j * 16 + i * 64;
                x = x + 1;
                C(x, y) = 1 + k * 4 + j * 16 + i * 64;
                x = x - 1; y = y + 1;
                C(x, y) = 2 + k * 4 + j * 16 + i * 64;
                x = x + 1;
                C(x, y) = 3 + k * 4 + j * 16 + i * 64;
            end
        end
    end
    D = C';

    %��֤������
    A8 = 8.^ones(8, 8);
    A4 = 4.^ones(4, 4);
    A16 = 16.^ones(16, 16);
    A32 = 32.^ones(32, 32);
    A64 = 64.^ones(64, 64);
    B = [A32, [A16, A16; [A8, A8; A8, A8], A16]; A32, A32];
    idx = 1;
    a = 1;
    b = 1;
    c = 1;
    d = 1;
    %�����������е�����ת��Ϊ[�����꣬�����꣬���С��0����z��ɨ���ţ�]������
    for i = 1:4:64
        for j = 1:4:64
            a = (floor(i / B(i, j))) * B(i, j) + 1;
            b = (floor(j / B(i, j))) * B(i, j) + 1;
            if (a ~= c || b ~= d)
                idx = idx + 1;
            end
            L{idx} = [a, b, A(i, j), 0];
            c = L{idx}(1);
            d = L{idx}(2);
        end
    end
    %ȥ��Ԫ���������ظ���Ԫ����������Ϊ��ȡ��������Ϣ��Ϊһ��Сbug����һ�����ظ���
    L = cellfun(@num2str, L, 'un', 0);
    K = unique(L);
    P = cellfun(@str2num, K, 'un', 0);
    s = size(P);
    %��¼��z��ɨ���е�˳��
    for i = 1:s(2)
        order = D((P{i}(1) - 1) / 4 + 1, (P{i}(2) - 1) / 4 + 1);
        P{i}(4) = order;
    end
    M = cell2mat(P');
    N = sortrows(M, 4); %��˳����������
    Po = mat2cell(N, [1 1 1 1 1 1 1 1 1 1]);
    sum = 0;
    sum8 = 0;
    sum16 = 0;
    sum32 = 0;
    sum64 = 0;
    for k = 1:s(2)
        switch P{k}(3)
            case 64
                sum64 = sum64 + 1;
            case 32
                sum32 = sum32 + 1;
            case 16
                sum16 = sum16 + 1;
            case 8
                sum8 = sum8 + 1;
        end
    end
    %�Ĳ�����ռ�������ĳ���
    sum = 5 * sum8 / 4 + sum16 + sum8 / 4 + sum32 + (sum16 + sum8 / 4) / 4;

function N = getlocationsizeorder(csvname)

    %��������z��ɨ���˳�����
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
    %���ս���洢��Ԫ������pul�У�ÿ��Ԫ������һ���ָ����pu�飬������3�����ݣ�����ǰpu�����꣨���к��У�
    while ~feof(fin)
        str = fgetl(fin); %��ȡһ��
        ctuno = regexp(str, '(?<=tu;)[0-9]+', 'match'); %���ڵ�һ���Ҳ�ȡ�Ĵ�ʩ
        if ~isempty(ctuno)
            no = str2double(ctuno);
        end
        ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %ȡ��'ctu location;'���������
        if ~isempty(ctutemp)
            ctu = strsplit(ctutemp{1}, 'x'); %�ָ
            ctul = [str2double(ctu{1}) str2double(ctu{2})]; %���ַ���ת��Ϊ����  ���������ִ���ctuʵ������
        end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %ȡ��pu rect;���������
        if ~isempty(n)
            src = strsplit(n{1}, ','); %�����ַָ���
            pul{idx} = [str2double(src{1}) str2double(src{2}) str2double(src{3})]; %ת��Ϊ���ִ浽pul�ĵ�һ��Ԫ����
            %        a=str2double(src{1})/4+1;
            %        b=str2double(src{2})/4+1;
            order = A(str2double(src{1}) / 4 + 1, str2double(src{2}) / 4 + 1);
            order = order + no * 256;
            pul{idx}(1) = pul{idx}(1) + ctul(1); %pu rect���ǰ�������ִ�������ڵ�ǰctu���������
            pul{idx}(2) = pul{idx}(2) + ctul(2); %����ʵ���������������꣫ctu����
            pul{idx} = [pul{idx}(1), pul{idx}(2), pul{idx}(3), order];
            idx = idx + 1;
        end
    end
    M = cell2mat(pul');
    N = sortrows(M, 4); %����ɨ��˳������󣬰��е�˳��
    fclose(fin);

end

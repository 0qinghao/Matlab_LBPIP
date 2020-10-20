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
    %���ս���洢��Ԫ������pul�У�ÿ��Ԫ������һ���ָ����pu�飬������3�����ݣ�����ǰpu�����꣨���к��У�
    while ~feof(fin)
        str = fgetl(fin); %��ȡһ��
        %    ctuno=regexp(str, '(?<=tu;)[0-9]+', 'match');%���ڵ�һ���Ҳ�ȡ�Ĵ�ʩ
        %    if ~isempty(ctuno)
        %       no=str2double(ctuno);
        %    end
        %    ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %ȡ��'ctu location;'���������
        %    if ~isempty(ctutemp)
        %        ctu = strsplit(ctutemp{1}, 'x'); %�ָ
        %        ctul = [str2double(ctu{1}) str2double(ctu{2})]; %���ַ���ת��Ϊ����  ���������ִ���ctuʵ������
        %    end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %ȡ��pu rect;���������
        if ~isempty(n)
            src = strsplit(n{1}, ','); %�����ַָ���
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
        m = regexp(str, '(?<=tu\ rect/qp;)([0-9]+,){2}[0-9]+', 'match'); %ȡ��tu rect;���������
        if ~isempty(m)
            srcm = strsplit(m{1}, ','); %�����ַָ���
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

function [pul] = getlocationsize(csvname)
    % fin=fopen('str.bin_block_info_0.txt','r');
    fin = fopen(csvname, 'r', 'l');
    idx = 1;
    %���ս���洢��Ԫ������pul�У�ÿ��Ԫ������һ���ָ����pu�飬������3�����ݣ�����ǰpu�����꣨���к��У�
    while ~feof(fin)
        str = fgetl(fin); %��ȡһ��
        ctutemp = regexp(str, '(?<=ctu\ location;)[0-9]+x[0-9]+', 'match'); %ȡ��'ctu location;'���������
        if ~isempty(ctutemp)
            ctu = strsplit(ctutemp{1}, 'x'); %�ָ
            ctul = [str2double(ctu{1}) str2double(ctu{2})]; %���ַ���ת��Ϊ����  ���������ִ���ctuʵ������
        end
        n = regexp(str, '(?<=pu\ rect;)([0-9]+,){2}[0-9]+', 'match'); %ȡ��pu rect;���������
        if ~isempty(n)
            src = strsplit(n{1}, ','); %�����ַָ���
            pul{idx} = [str2double(src{1}) str2double(src{2}) str2double(src{3})]; %ת��Ϊ���ִ浽pul�ĵ�һ��Ԫ����
            pul{idx}(1) = pul{idx}(1) + ctul(1); %pu rect���ǰ�������ִ�������ڵ�ǰctu���������
            pul{idx}(2) = pul{idx}(2) + ctul(2); %����ʵ���������������꣫ctu����
            idx = idx + 1;
        end
    end
    fclose(fin);
end

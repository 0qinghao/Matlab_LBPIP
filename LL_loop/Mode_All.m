function mode_all = Mode_All(mode_all, a, b, N, mode)
    %UNTITLED3 �˴���ʾ�йش˺�����ժҪ
    %   �˴���ʾ��ϸ˵��
    for i = a:a + N - 1
        for j = b:b + N - 1
            mode_all(i, j) = mode;
        end
    end
end

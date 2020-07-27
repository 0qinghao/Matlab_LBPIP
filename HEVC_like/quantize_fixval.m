function out = quantize_fixval(in, color_num, Q_fix)
    % TODO:fixval阈值还是可以做. 好处:不需要发送给接收端, 我在编码时自己判断要不要记录这个点的修正值就行了

    if (color_num == 1)
        outputData = round(in ./ Q_fix);
    elseif (color_num == 2 || color_num == 3)
        outputData = round(in ./ Q_fix);
    end
    % if strcmp(code, 'lum')
    %     % index = 1;
    %     % for x = 1:numel(in)
    %     % for y = 1:8
    %     % outputData(index) = round(in(i, j) *  divLumMatrix(index));
    %     outputData = round(in / Qfixval);
    %     % index=index+1;
    %     % end
    %     % end
    % elseif strcmp(code, 'chrom')
    %     % index = 1;
    %     % for x = 1:numel(in)
    %     % for y = 1:8
    %     % outputData(index) = round(in(i, j) *  divChromMatrix(index));
    %     outputData = round(in / Qfixval);
    %     % index=index+1;
    %     % end
    %     % end
    % end

    out = outputData;
end

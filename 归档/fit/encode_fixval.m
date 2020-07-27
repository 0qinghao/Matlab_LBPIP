% function encode_fixval(fix_val, fixvalName)
function encode_fixval(b4_enc_base_fixval_cell, b4_enc_fixval_cell, fixvalName)
    fid1 = fopen([fixvalName, '1'], 'w');
    fid2 = fopen([fixvalName, '2'], 'w');

    % global cnt_code;
    % cnt_code = zeros(2, 251);

    for i = 1:size(b4_enc_base_fixval_cell, 1)
        for j = 1:size(b4_enc_base_fixval_cell, 2)
            fixy = b4_enc_base_fixval_cell{i, j}(:, :, 1);
            fixu = b4_enc_base_fixval_cell{i, j}(:, :, 2);
            fixv = b4_enc_base_fixval_cell{i, j}(:, :, 3);
            fixyuv = [fixy(:); fixu(:); fixv(:)];
            huffman_fix(fid1, fixyuv);
        end
    end
    flashBuffer(fid1);
    writeEOI(fid1);
    fclose(fid1);

    global mode_sum;
    for i = 1:size(b4_enc_fixval_cell, 1)
        for j = 1:size(b4_enc_fixval_cell, 2)
            fixyuv_s = [];
            fixallcell = b4_enc_fixval_cell{i, j};
            mode_sum = mode_sum + numel(fixallcell);
            for m = 1:size(fixallcell, 1)
                for n = 1:size(fixallcell, 2)
                    fixyuv_s = [fixyuv_s(:); fixallcell{m, n}(:)];
                end
            end
            huffman_fix(fid2, fixyuv_s);
            % fixu = b4_enc_fixval_cell{i, j}(:, :, :, 2);
            % fixv = b4_enc_fixval_cell{i, j}(:, :, :, 3);
            % [~, ~, cnt] = size(fixy);
            % for k = 1:cnt
            %     huffman_fix(fid2, fixy(:, :, k));
            %     huffman_fix(fid2, fixu(:, :, k));
            %     huffman_fix(fid2, fixv(:, :, k));
            % end
        end
    end
    flashBuffer(fid2);
    writeEOI(fid2);
    fclose(fid2);
end

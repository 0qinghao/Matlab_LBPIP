function [b4_enc_base_pix, b4_enc_base_fixval, b4_enc_fixval, pre_mode, decode_block] = encode_top_linespace(yuv_block, TH_fix, TH_div, quality)
    mode_cnt = 10;
    yuv_block = double(yuv_block);
    decode_block = zeros(40, 40, 3);
    b4_enc_fixval_sub = {}; fixed_src_sub = {}; MAE = {}; fix_cnt = {}; pre_mode = {}; b4_enc_fixval = {};

    SIZE = 40;
    % [base_pix, dec_base_pix, b4_enc_base_pix] = get_base_pix_const(yuv_block, SIZE, quality);
    [base_pix, base_pix_filtered, dec_base_pix, b4_enc_base_pix] = get_base_pix_filtered_const(yuv_block, SIZE, quality);
    % [fixed_base, b4_enc_base_fixval] = fix_base(base_pix, dec_base_pix, Q_fix, SIZE);
    % [fixed_base, b4_enc_base_fixval] = fix_base(base_pix, dec_base_pix, TH_fix * 2, SIZE);
    % 测试不单独做修正, 只对大误差块做修正
    fixed_base = zeros(SIZE, SIZE, 3);
    switch SIZE
        case 20
            base_index = [[43:5:60]', 100 + [43:5:60]', 200 + [43:5:60]', 300 + [43:5:60]'];
        case 40
            base_index = [[83:5:120]', 200 + [83:5:120]', 400 + [83:5:120]', 600 + [83:5:120]', 800 + [83:5:120]', 1000 + [83:5:120]', 1200 + [83:5:120]', 1400 + [83:5:120]'];
    end
    for i = 1:3
        fixed_base(base_index + (i - 1) * SIZE^2) = dec_base_pix(:, :, i);
    end

    for color_num = 1:3
        % 尝试按40x40预测
        dst40 = yuv_block(:, :, color_num);
        src40 = fixed_base(:, :, color_num);
        for mode = 1:mode_cnt
            % [b4_enc_fixval_sub{mode}, fixed_src_sub{mode}, MAE{mode}, fix_cnt{mode}] = linespace_pre(mode, dst40, src40, Q_fix, color_num);
            [b4_enc_fixval_sub{mode}, fixed_src_sub{mode}, MAE{mode}, fix_cnt{mode}] = linespace_pre(mode, dst40, src40, TH_fix, color_num);
        end
        if (min(cell2mat(fix_cnt))) >= 40 * 40 * TH_div
            % 如果修正值数量超过了阈值, 尝试20x20预测
            SIZE = 20;
            dst20 = img_mat2cell(dst40, SIZE);
            src20 = img_mat2cell(src40, SIZE);
            for i = 1:4
                [x20, y20] = ind2sub(size(dst20), i);
                for mode = 1:mode_cnt
                    [b4_enc_fixval_sub{mode}, fixed_src_sub{mode}, MAE{mode}, fix_cnt{mode}] = linespace_pre(mode, dst20{i}, src20{i}, TH_fix, color_num);
                end
                if (min(cell2mat(fix_cnt))) >= 20 * 20 * TH_div
                    % 如果修正值数量超过了阈值, 尝试10x10预测
                    SIZE = 10;
                    dst10 = img_mat2cell(dst20{i}, SIZE);
                    src10 = img_mat2cell(src20{i}, SIZE);
                    for j = 1:4
                        [x10, y10] = ind2sub(size(dst10), j);
                        for mode = 1:mode_cnt
                            [b4_enc_fixval_sub{mode}, fixed_src_sub{mode}, MAE{mode}, fix_cnt{mode}] = linespace_pre(mode, dst10{j}, src10{j}, TH_fix, color_num);
                        end
                        if (min(cell2mat(fix_cnt))) >= 10 * 10 * TH_div
                            % 如果修正值数量超过了阈值, 尝试5x5预测
                            SIZE = 5;
                            dst5 = img_mat2cell(dst10{j}, SIZE);
                            src5 = img_mat2cell(src10{j}, SIZE);
                            for k = 1:4
                                [x5, y5] = ind2sub(size(dst5), k);
                                for mode = 1:mode_cnt
                                    [b4_enc_fixval_sub{mode}, fixed_src_sub{mode}, MAE{mode}, fix_cnt{mode}] = linespace_pre(mode, dst5{k}, src5{k}, TH_fix, color_num);
                                end
                                [~, mode_temp] = min(cell2mat(fix_cnt)); %选修正值最少的
                                pre_mode{end + 1} = mode_temp;
                                b4_enc_fixval{end + 1} = b4_enc_fixval_sub{mode_temp};
                                decode_block((x20 - 1) * 20 + 1 + (x10 - 1) * 10 + (x5 - 1) * 5:(x20 - 1) * 20 + (x10 - 1) * 10 + (x5 - 1) * 5 + 5, (y20 - 1) * 20 + 1 + (y10 - 1) * 10 + (y5 - 1) * 5:(y20 - 1) * 20 + (y10 - 1) * 10 + (y5 - 1) * 5 + 5, color_num) = fixed_src_sub{mode_temp};
                            end
                        else
                            [~, mode_temp] = min(cell2mat(fix_cnt)); %选修正值最少的
                            pre_mode{end + 1} = mode_temp;
                            b4_enc_fixval{end + 1} = b4_enc_fixval_sub{mode_temp};
                            decode_block((x20 - 1) * 20 + 1 + (x10 - 1) * 10:(x20 - 1) * 20 + (x10 - 1) * 10 + 10, (y20 - 1) * 20 + 1 + (y10 - 1) * 10:(y20 - 1) * 20 + (y10 - 1) * 10 + 10, color_num) = fixed_src_sub{mode_temp};
                        end
                    end
                else
                    [~, mode_temp] = min(cell2mat(fix_cnt)); %选修正值最少的
                    pre_mode{end + 1} = mode_temp;
                    b4_enc_fixval{end + 1} = b4_enc_fixval_sub{mode_temp};
                    decode_block((x20 - 1) * 20 + 1:(x20 - 1) * 20 + 20, (y20 - 1) * 20 + 1:(y20 - 1) * 20 + 20, color_num) = fixed_src_sub{mode_temp};
                end
            end
        else
            [~, mode_temp] = min(cell2mat(fix_cnt)); %选修正值最少的
            pre_mode{end + 1} = mode_temp;
            b4_enc_fixval{end + 1} = b4_enc_fixval_sub{mode_temp};
            decode_block(1:40, 1:40, color_num) = fixed_src_sub{mode_temp};
        end
    end
end

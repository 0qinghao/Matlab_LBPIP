function [err, pred, sae, dir, w1, w2, preview] = alldirection_allweight_test_4(inputName, direction_num)
    clear err pred sae dir w1 w2 preview
    rgb = imread(inputName);
    yuv = double(jpeg_rgb2ycbcr(rgb));
    lum = yuv(:, :, 1);
    err = {}; pred = {}; sae = {}; dir = {}; preview = {}; w1 = {}; w2 = {};
    for x = 2:4:108 - 7
        for y = 2:4:192 - 7
            src = lum(x:x + 3, y:y + 3);
            T = lum(x - 1, y:y + 7);
            L = lum(x:x + 7, y - 1);
            LT = lum(x - 1, y - 1);

            [err{end + 1}, pred{end + 1}, sae{end + 1}, dir{end + 1}, w1{end + 1}, w2{end + 1}] = direction_weight_select_4(L, T, LT, src, direction_num);
            preview{end + 1} = [LT, T(1:4); [L(1:4), src]];
        end
    end
    sae = cell2mat(sae);
    dir = cell2mat(dir);
end

function [err, pred, sae, dir, w1, w2] = direction_weight_select_4(L, T, LT, src, direction_num)
    NUM = direction_num;
    for N = 1:NUM
        theta = 45 + ((225 - 45) / (NUM - 1)) * (N - 1);
        [ref1_val{N}, ref2_val{N}] = get_ref1_2(L, T, LT, theta);

        % M = 1;
        % for w1 = -2:0.05:2
        %     [err_allw{M}, pred_allw{M}, sae_allw(M)] = pred_by_w(src, ref1_val{N}, ref2_val{N}, w1);
        %     w1_all(M) = w1;
        %     M = M + 1;
        % end
        M = 1;
        for w1 = -2:0.05:2
            for w2 = -2:0.05:2
                [err_allw{M}, pred_allw{M}, sae_allw(M)] = pred_by_w_nolimit(src, ref1_val{N}, ref2_val{N}, w1, w2);
                w1_all(M) = w1;
                w2_all(M) = w2;
                M = M + 1;
            end
        end

        [sae_best(N), ind_best] = min(sae_allw);
        err_best{N} = err_allw{ind_best};
        pred_best{N} = pred_allw{ind_best};
        w1_best(N) = w1_all(ind_best);
        w2_best(N) = w2_all(ind_best);
    end

    [sae, dir] = min(sae_best);
    pred = pred_best{dir};
    err = err_best{dir};
    w1 = w1_best(dir);
    w2 = w2_best(dir);
end

function [ref1_val, ref2_val] = get_ref1_2(L, T, LT, theta)
    v_mat = [1, 1, 1, 1; 2, 2, 2, 2; 3, 3, 3, 3; 4, 4, 4, 4];
    h_mat = v_mat';
    if theta <= 90
        % 暂时不考虑 90 度没法算的问题，因为不会出现这个角度
        offset = v_mat / tand(theta);
        proj_pos = h_mat + offset;
        ref1_index = floor(proj_pos);
        ref2_index = ceil(proj_pos);
        ref1_val = T(ref1_index);
        ref2_val = T(ref2_index);
        % weight1 = ref2_index - proj_pos;
        % weight2 = proj_pos - ref1_index;
        % weight1(weight1 == 0) = 1;
        % pred = round(weight1 .* ref1_val + weight2 .* ref2_val);
        % err = src - pred;
        % sae = sum(sum(abs(err)));
    elseif theta >= 180
        % 暂时不考虑 180 度没法算的问题，因为不会出现这个角度
        offset = h_mat * tand(theta - 180);
        proj_pos = v_mat + offset;
        ref1_index = floor(proj_pos);
        ref2_index = ceil(proj_pos);
        ref1_val = L(ref1_index);
        ref2_val = L(ref2_index);
        % weight1 = ref2_index - proj_pos;
        % weight2 = proj_pos - ref1_index;
        % weight1(weight1 == 0) = 1;
        % pred = round(weight1 .* ref1_val + weight2 .* ref2_val);
        % err = src - pred;
        % sae = sum(sum(abs(err)));
    else
        % 要考虑投影到上方还是左方，还要考虑 LT 这个参考点
        offset_h = v_mat / tand(180 - theta);
        proj_pos_h = h_mat - offset_h;
        offset_v = h_mat * tand(180 - theta);
        proj_pos_v = v_mat - offset_v;
        proj_T_flag = proj_pos_h >= 0;
        proj_L_falg = not(proj_T_flag);
        for i = 1:4
            for j = 1:4
                if proj_T_flag(i, j)
                    ref1_index = floor(proj_pos_h(i, j));
                    ref2_index = ceil(proj_pos_h(i, j));
                    if ref1_index == 0
                        ref1_val(i, j) = LT;
                    else
                        ref1_val(i, j) = T(ref1_index);
                    end
                    ref2_val(i, j) = T(ref2_index);
                    % weight1(i, j) = ref2_index - proj_pos_h(i, j);
                    % weight2(i, j) = proj_pos_h(i, j) - ref1_index;
                else
                    ref1_index = floor(proj_pos_v(i, j));
                    ref2_index = ceil(proj_pos_v(i, j));
                    if ref1_index == 0
                        ref1_val(i, j) = LT;
                    else
                        ref1_val(i, j) = L(ref1_index);
                    end
                    ref2_val(i, j) = L(ref2_index);
                    % weight1(i, j) = ref2_index - proj_pos_v(i, j);
                    % weight2(i, j) = proj_pos_v(i, j) - ref1_index;
                end
            end
        end
        % weight1(weight1 == 0) = 1;
        % pred = round(weight1 .* ref1_val + weight2 .* ref2_val);
        % err = src - pred;
        % sae = sum(sum(abs(err)));
    end
end

function [err, pred, sae] = pred_by_w(src, ref1_val, ref2_val, w1)
    w2 = 1 - w1;
    pred = w1 * ref1_val + w2 * ref2_val;
    err = src - pred;
    sae = sum(sum(abs(err)));
end

function [err, pred, sae] = pred_by_w_nolimit(src, ref1_val, ref2_val, w1, w2)
    pred = w1 * ref1_val + w2 * ref2_val;
    err = src - pred;
    sae = sum(sum(abs(err)));
end

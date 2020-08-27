function [SAE_t, SIZE_t, SAE_l, SIZE_l] = compare_loop_dct()
    % function [SSE_t, SIZE_t, SSE_l, SIZE_l] = compare_loop_dct()
    SAE_t = [];
    SIZE_t = [];
    SAE_l = [];
    SIZE_l = [];

    initGlobals(93);
    restore_ind1 = [1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16	1	2	3	4	5	6	7	8	1	2	9	3	4	10	5	1	6	11	2	7	3	4	8	12	1	5	2	9	6	3	1	4	7	10	13	2	5	8	3	1	6	11	4	2	9	7	5	3	1	2	4	6	8	10	12	14	1	3	5	7	2	9	4	1	6	11	3	8	5	2	1	4	7	10	13	3	6	2	9	5	1	4	8	12	3	7	2	1	6	11	5	4	10	3	2	9	1	8	7	6	5	4	3	2	1	3	5	1	2	4	6	7	8	9	10	11	12	13	14	15	1	2	3	4	5	6	7	8	1	2	9	3	4	10	5	1	6	11	2	7	3	4	8	12	1	5	2	9	6	3	1	4	7	10	13	2	5	8	3	1	6	11	4	2	9	7	5	3	1	2	4	6	8	10	12	14	1	3	5	7	2	9	4	1	6	11	3	8	5	2	1	4	7	10	13	3	6	2	9	5	1	4	8	12	3	7	2	1	6	11	5	4	10	3	2	9	1	8	7	6	5	4	3	2	1	3	5	1	2	4	6	7	8	9	10	11	12	13	14	15];
    restore_ind2 = [1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	2	2	2	2	2	2	2	3	3	2	3	3	2	3	4	3	2	4	3	4	4	3	2	5	4	5	3	4	5	6	5	4	3	2	6	5	4	6	7	5	3	6	7	4	5	6	7	8	8	7	6	5	4	3	2	9	8	7	6	9	5	8	10	7	4	9	6	8	10	11	9	7	5	3	10	8	11	6	9	12	10	7	4	11	8	12	13	9	5	10	11	6	12	13	7	14	8	9	10	11	12	13	14	15	14	12	16	15	13	11	10	9	8	7	6	5	4	3	2	17	16	15	14	13	12	11	10	18	17	9	16	15	8	14	19	13	7	18	12	17	16	11	6	20	15	19	10	14	18	21	17	13	9	5	20	16	12	19	22	15	8	18	21	11	14	17	20	23	22	19	16	13	10	7	4	24	21	18	15	23	12	20	25	17	9	22	14	19	24	26	21	16	11	6	23	18	25	13	20	27	22	15	8	24	17	26	28	19	10	21	23	12	25	27	14	29	16	18	20	22	24	26	28	30	27	23	31	29	25	21	19	17	15	13	11	9	7	5	3];

    Q = 8;

    test_cnt = 1;
    for M = linspace(2, 15, 10000)
        err = round((rand(16, 16) - 0.5) * M);

        % load('./err_kitchen_y.mat');
        % [height, width] = size(err_kitchen_y);
        % height_cnt = height / 16;
        % width_cnt = width / 16;

        % for x = 1:height_cnt
        %     for y = 1:width_cnt
        % err = err_kitchen_y((x - 1) * 16 + 1:x * 16, (y - 1) * 16 + 1:y * 16);

        dct_t = round(dct2(err));
        dctQ_t = round(dct_t / Q);
        temp_dQ = round(dctQ_t * Q);
        err_r_t = round(idct2(temp_dQ));
        sae_t = sum(abs(err_r_t - err), [1, 2]);
        % sse_t = sum((err_r_t - err).^2, [1, 2]);

        zz_t = zigzag_2dto1d(dctQ_t);
        fid = fopen("t.ecs", 'w');
        huffman(fid, zz_t);
        size_t = ftell(fid);
        fclose(fid);

        err_r_l = zeros(16, 16);
        dctQ_l = zeros(16, 16);
        dctQ_l_forecs = zeros(16, 16 + 15);
        for i = 1:15
            loop_data = [err(16:-1:i, i)', err(i, i + 1:16)];

            dct_l_sub = round(dct(loop_data));
            dctQ_l_sub = round(dct_l_sub / Q);
            dctQ_l(16:-1:i, i) = dctQ_l_sub(1:(numel(dctQ_l_sub) + 1) / 2);
            dctQ_l(i, i + 1:16) = dctQ_l_sub((numel(dctQ_l_sub) + 1) / 2 + 1:end);

            dctQ_l_forecs(i, 1:numel(dctQ_l_sub)) = dctQ_l_sub;

            temp_dQ = round(dctQ_l_sub * Q);
            temp_idct_l = round(idct(temp_dQ));
            err_r_l(16:-1:i, i) = temp_idct_l(1:(numel(temp_idct_l) + 1) / 2);
            err_r_l(i, i + 1:16) = temp_idct_l((numel(temp_idct_l) + 1) / 2 + 1:end);
        end
        dctQ_l(16, 16) = round(err(16, 16) / Q);
        dctQ_l_forecs(16, 1) = dctQ_l(16, 16);
        err_r_l(16, 16) = round(dctQ_l(16, 16) * Q);
        sae_l = sum(abs(err_r_l -err), [1, 2]);
        % sse_l = sum((err_r_l -err).^2, [1, 2]);
        restore_l = zeros(1, 16 * 16);
        for cnt = 1:256
            restore_l(cnt) = dctQ_l_forecs(restore_ind1(cnt), restore_ind2(cnt));
        end
        fid = fopen("l.ecs", 'w');
        huffman(fid, restore_l);
        size_l = ftell(fid);
        fclose(fid);
        %     end
        % end
        SAE_t(test_cnt) = sae_t;
        % SSE_t(test_cnt) = sse_t;
        SIZE_t(test_cnt) = size_t;
        SAE_l(test_cnt) = sae_l;
        % SSE_l(test_cnt) = sse_l;
        SIZE_l(test_cnt) = size_l;

        test_cnt = test_cnt + 1;
    end
    % plot(SSE_t, SIZE_t, 'b.', SSE_l, SIZE_l, 'r.')
    plot(SAE_t, SIZE_t, 'b.', SAE_l, SIZE_l, 'r.')
end

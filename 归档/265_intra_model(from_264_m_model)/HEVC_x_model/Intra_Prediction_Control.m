function encoded_pixels = Intra_Prediction_Control(mb_buf, CU_Size, image_wide, image_high, PU)

    file_size = image_wide * image_high;
    encoded_pixels = zeros(35, file_size);

    % # of Coding Unit and Prediction Unit Size
    no_of_CU = (image_wide * image_high) / (CU_Size * CU_Size);
    no_of_PU = (CU_Size * CU_Size) / (PU * PU);

    % Index Parameters for Different PU Sizes
    T_Index_4 = [1 1 2 2 1 1 2 2 3 3 4 4 3 3 4 4 1 1 2 2 1 1 2 2 3 3 4 4 3 3 4 4 5 5 6 6 5 5 6 6 7 7 8 8 7 7 8 8 5 5 6 6 5 5 6 6 7 7 8 8 7 7 8 8 ...
                1 1 2 2 1 1 2 2 3 3 4 4 3 3 4 4 1 1 2 2 1 1 2 2 3 3 4 4 3 3 4 4 5 5 6 6 5 5 6 6 7 7 8 8 7 7 8 8 5 5 6 6 5 5 6 6 7 7 8 8 7 7 8 8 ...
                9 9 10 10 9 9 10 10 11 11 12 12 11 11 12 12 9 9 10 10 9 9 10 10 11 11 12 12 11 11 12 12 13 13 14 14 13 13 14 14 15 15 16 16 15 15 16 16 13 13 14 14 13 13 14 14 15 15 16 16 15 15 16 16 ...
                9 9 10 10 9 9 10 10 11 11 12 12 11 11 12 12 9 9 10 10 9 9 10 10 11 11 12 12 11 11 12 12 13 13 14 14 13 13 14 14 15 15 16 16 15 15 16 16 13 13 14 14 13 13 14 14 15 15 16 16 15 15 16 16];
    L_Index_4 = [1 2 1 2 3 4 3 4 1 2 1 2 3 4 3 4 5 6 5 6 7 8 7 8 5 6 5 6 7 8 7 8 1 2 1 2 3 4 3 4 1 2 1 2 3 4 3 4 5 6 5 6 7 8 7 8 5 6 5 6 7 8 7 8 ...
                9 10 9 10 11 12 11 12 9 10 9 10 11 12 11 12 13 14 13 14 15 16 15 16 13 14 13 14 15 16 15 16 9 10 9 10 11 12 11 12 9 10 9 10 11 12 11 12 13 14 13 14 15 16 15 16 13 14 13 14 15 16 15 16 ...
                1 2 1 2 3 4 3 4 1 2 1 2 3 4 3 4 5 6 5 6 7 8 7 8 5 6 5 6 7 8 7 8 1 2 1 2 3 4 3 4 1 2 1 2 3 4 3 4 5 6 5 6 7 8 7 8 5 6 5 6 7 8 7 8 ...
                9 10 9 10 11 12 11 12 9 10 9 10 11 12 11 12 13 14 13 14 15 16 15 16 13 14 13 14 15 16 15 16 9 10 9 10 11 12 11 12 9 10 9 10 11 12 11 12 13 14 13 14 15 16 15 16 13 14 13 14 15 16 15 16];

    T_Index_8 = [1 1 3 3 1 1 3 3 5 5 7 7 5 5 7 7 1 1 3 3 1 1 3 3 5 5 7 7 5 5 7 7 9 9 11 11 9 9 11 11 13 13 15 15 13 13 15 15 9 9 11 11 9 9 11 11 13 13 15 15 13 13 15 15];
    L_Index_8 = [1 3 1 3 5 7 5 7 1 3 1 3 5 7 5 7 9 11 9 11 13 15 13 15 9 11 9 11 13 15 13 15 1 3 1 3 5 7 5 7 1 3 1 3 5 7 5 7 9 11 9 11 13 15 13 15 9 11 9 11 13 15 13 15];

    T_Index_16 = [1 1 5 5 1 1 5 5 9 9 13 13 9 9 13 13];
    L_Index_16 = [1 5 1 5 9 13 9 13 1 5 1 5 9 13 9 13];

    T_Index_32 = [1 1 9 9];
    L_Index_32 = [1 9 1 9];

    % Index Selection with PU Size
    if (PU == 4)
        T_Index_N = T_Index_4;
        L_Index_N = L_Index_4;
    elseif (PU == 8)
        T_Index_N = T_Index_8;
        L_Index_N = L_Index_8;
    elseif (PU == 16)
        T_Index_N = T_Index_16;
        L_Index_N = L_Index_16;
    else
        T_Index_N = T_Index_32;
        L_Index_N = L_Index_32;
    end

    Top_Neighbor_CU = zeros(16, 96);
    Left_Neighbor_CU = zeros(16, 96);
    R_Neigh_CU = zeros(16, 16);

    Row_End = image_wide / CU_Size; % Check the end of row.
    Row_End_Pixels = 128 * ones(1, 32);
    for m = 0:no_of_CU - 1
        % m;
        % Generate All Possible Neighboring Pixels.
        for j = 1:16

            if (mod(m + 1, Row_End) == 0)% Row End
                Top_Neighbor_CU(j, :) = [mb_buf((4096 * m + (((j) * 64 * 4 - 64) + 1)):(4096 * m + (((j) * 64 * 4 - 64) + 64))) Row_End_Pixels];
            elseif ((m < Row_End) && (j == 1))% First Row
                Top_Neighbor_CU(j, :) = 128 * ones(1, 96);
            else % Others
                Top_Neighbor_CU(j, :) = mb_buf((4096 * m + (((j) * 64 * 4 - 64) + 1)):(4096 * m + (((j) * 64 * 4 - 64) + 96)));
            end

            if ((mod(m, Row_End) == 0) && (j == 1))% First Column
                Left_Neighbor_CU(j, :) = 128 * ones(1, 96);
            elseif (((m + 1) >= (no_of_CU - Row_End)) && (j > 1))% Column End
                Left_Neighbor_CU(j, :) = [mb_buf((4096 * m + ((j - 1) * 4)):64:(4096 * m + (((j - 1) * 4) + 4032))) Row_End_Pixels]; %[mb_buf((4096*m+(((j)*64*4-64)+1)):64:(4096*m+(((j)*64*4-64)+4096))) Row_End_Pixels];
            elseif (((m + 1) >= (no_of_CU - Row_End)) && (j == 1))
                Left_Neighbor_CU(j, :) = [mb_buf((4096 * m + (((j - 1) * 4032 * 4 - 4032))):64:(4096 * m + (((j - 1) * 4032 * 4)))) Row_End_Pixels];
            elseif (j == 1)
                Left_Neighbor_CU(j, 1:64) = mb_buf((4096 * m + (((j - 1) * 4032 * 4 - 4032))):64:(4096 * m + (((j - 1) * 4032 * 4))));
                Left_Neighbor_CU(j, 65:96) = mb_buf((4096 * m + (((j - 1) * 4032 * 4 - 4032)) + 4096 * (1920/64)):64:(4096 * m + (((j - 1) * 4032 * 4 - 2048)) + 4096 * (1920/64)));
            else % Others
                Left_Neighbor_CU(j, 1:64) = mb_buf((4096 * m + ((j - 1) * 4)):64:(4096 * m + (((j - 1) * 4) + 4032)));
                Left_Neighbor_CU(j, 65:96) = mb_buf((4096 * m + (((j - 1) * 4))) + 4096 * (1920/64):64:(4096 * m + (((j - 1) * 4))) + 4096 * (1920/64) + 1984);
            end

            if (((m < Row_End) && (j == 1)) || ((mod(m, Row_End) == 0) && (j == 1)))
                R_Neigh_CU(j, :) = 128;
            else
                R_Neigh_CU(j, :) = mb_buf((4096 * m + (((j) * 64 * 4) - 64)):4:(4096 * m + (((j) * 64 * 4) - 4)));
            end

        end

        % Generate Neighboring Pixels
        for i = 0:(no_of_PU) - 1

            PY(2:(2 * PU + 1)) = Top_Neighbor_CU (T_Index_N(i + 1), ((L_Index_N(i + 1) - 1) * 4 + 1):((L_Index_N(i + 1) - 1) * 4 + 2 * PU));
            PX(2:(2 * PU + 1)) = Left_Neighbor_CU(L_Index_N(i + 1), ((T_Index_N(i + 1) - 1) * 4 + 1):((T_Index_N(i + 1) - 1) * 4 + 2 * PU));

            PY(1) = R_Neigh_CU(T_Index_N(i + 1), L_Index_N(i + 1));
            PX(1) = R_Neigh_CU(T_Index_N(i + 1), L_Index_N(i + 1));

            % Smoothing Filter
            [PF_X, PF_Y] = Intra_Smoothing(PU, PX, PY);

            % Intra DC Prediction
            Intra_DC = DC_Model(PU, PX, PY);

            % Intra Planar Prediction
            Intra_Planar = Planar_Model(PU, PX, PY);

            % Intra Angular Prediction
            [iFact, Intra_Angular] = Intra_Angular_Model(double(PY), double(PX), double(PF_Y), double(PF_X), PU);

            %       for j=1:n_mode
            for k = 1:PU
                for l = 1:PU
                    encoded_pixels(1, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_DC(k, l);
                    encoded_pixels(2, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Planar(k, l);
                    encoded_pixels(3, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{1}(k, l);
                    encoded_pixels(4, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{2}(k, l);
                    encoded_pixels(5, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{3}(k, l);
                    encoded_pixels(6, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{4}(k, l);
                    encoded_pixels(7, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{5}(k, l);
                    encoded_pixels(8, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{6}(k, l);
                    encoded_pixels(9, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{7}(k, l);
                    encoded_pixels(10, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{8}(k, l);
                    encoded_pixels(11, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{9}(k, l);
                    encoded_pixels(12, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{10}(k, l);
                    encoded_pixels(13, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{11}(k, l);
                    encoded_pixels(14, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{12}(k, l);
                    encoded_pixels(15, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{13}(k, l);
                    encoded_pixels(16, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{14}(k, l);
                    encoded_pixels(17, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{15}(k, l);
                    encoded_pixels(18, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{16}(k, l);
                    encoded_pixels(19, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{17}(k, l);
                    encoded_pixels(20, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{18}(k, l);
                    encoded_pixels(21, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{19}(k, l);
                    encoded_pixels(22, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{20}(k, l);
                    encoded_pixels(23, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{21}(k, l);
                    encoded_pixels(24, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{22}(k, l);
                    encoded_pixels(25, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{23}(k, l);
                    encoded_pixels(26, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{24}(k, l);
                    encoded_pixels(27, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{25}(k, l);
                    encoded_pixels(28, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{26}(k, l);
                    encoded_pixels(29, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{27}(k, l);
                    encoded_pixels(30, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{28}(k, l);
                    encoded_pixels(31, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{29}(k, l);
                    encoded_pixels(32, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{30}(k, l);
                    encoded_pixels(33, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{31}(k, l);
                    encoded_pixels(34, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{32}(k, l);
                    encoded_pixels(35, ((m * 4096) + (i * (PU * PU)) + (((k - 1) * PU) + l))) = Intra_Angular{33}(k, l);
                end
            end

        end
    end

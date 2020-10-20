function [iFact, Intra_Angular] = Intra_Angular_Model(Top_Pixels, Left_Pixels, Top_Filtered_Pixels, Left_Filtered_Pixels, nS)

    % Intra Angular Prediction Matlab Model
    % Inputs:
    %   Top_Pixels              : Top  neighboring pixels
    %   Left_Pixels             : Left neighboring pixels
    %   Top_Filtered_Pixels     : Top  neighboring pixels after smoothing filter
    %   Top_Filtered_Pixels     : Left  neighboring pixels after smoothing filter
    %   nS                      : Prediction unit size

    % Outputs:
    %   iFact                   : Multiplication Factor (iFact)
    %   Intra_Angular           : Intra Angular Predicted Pixels (In order to display Intra_Angular{1}  celldisp(Intra_Angular))

    intra_mode = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34]; % intra prediction mode
    intra_angle = [32 26 21 17 13 9 5 2 0 -2 -5 -9 -13 -17 -21 -26 -32 -26 -21 -17 -13 -9 -5 -2 0 2 5 9 13 17 21 26 32]; % intra prediction angle
    intra_inv_angle = [0 0 0 0 0 0 0 0 0 -4096 -1638 -910 -630 -482 -390 -315 -256 -315 -390 -482 -630 -910 -1638 -4096 0 0 0 0 0 0 0 0 0]; % intra prediction inverse angle

    if (nS == 4)
        n_mode = 33;
        twos_angle = 256;
    elseif (nS == 8)
        n_mode = 33;
        twos_angle = 256;
    elseif (nS == 16)
        n_mode = 33;
        twos_angle = 512;
    else
        n_mode = 33;
        twos_angle = 1024;
    end

    % calculate iFact multiplication factor
    for i = 1:n_mode
        for j = 1:nS
            if (j * intra_angle(i) < 0)
                twos_cmp_angle = twos_angle + (j * intra_angle(i));
                iFact(((i - 1) * nS) + j) = bitand(twos_cmp_angle, 31);
            else
                iFact(((i - 1) * nS) + j) = bitand((j * intra_angle(i)), 31);
            end
        end
    end

    % find refmain
    for i = 1:n_mode

        if (nS == 4)
            px = Left_Pixels;
            py = Top_Pixels;
        end

        if ((nS == 8) && ((n_mode == 2) || (n_mode == 18) || (n_mode == 34)))
            px = Left_Filtered_Pixels;
            py = Top_Filtered_Pixels;
        elseif (nS == 8)
            px = Left_Pixels;
            py = Top_Pixels;
        end

        if ((nS == 16) && ((n_mode == 9) || (n_mode == 10) || (n_mode == 11) || (n_mode == 26) || (n_mode == 27) || (n_mode == 28)))
            px = Left_Pixels;
            py = Top_Pixels;
        elseif (nS == 16)
            px = Left_Filtered_Pixels;
            py = Top_Filtered_Pixels;
        end

        if ((nS == 32) && ((n_mode == 10) || (n_mode == 26)))
            px = Left_Pixels;
            py = Top_Pixels;
        elseif (nS == 32)
            px = Left_Filtered_Pixels;
            py = Top_Filtered_Pixels;
        end

        % Reference Main Array Selection
        if (intra_mode(i) < 18)
            for j = (nS + 1):(2 * nS + 1)
                refmain(i, j) = px(j - nS);
            end

            if (intra_angle(i) < 0)
                x = nS * intra_angle(i);
                x_s = fix(x / 32);

                if (x_s < -1)
                    for x_ss = x_s:-1
                        refmain(i, x_ss + (nS + 1)) = py(1 + (fix(((x_ss) * intra_inv_angle(i) + 128) / 256)));
                    end
                end
            else
                for j = (2 * nS + 2):(3 * nS + 1)
                    refmain(i, j) = px(j - nS);
                end
            end
        else
            for j = (nS + 1):(2 * nS + 1)
                refmain(i, j) = py(j - nS);
            end

            if (intra_angle(i) < 0)
                x = nS * intra_angle(i);
                x_s = fix(x / 32);

                if (x_s < -1)
                    for x_ss = x_s:-1
                        refmain(i, x_ss + (nS + 1)) = px(1 + (fix(((x_ss) * intra_inv_angle(i) + 128) / 256)));
                    end
                end
            else
                for j = (2 * nS + 2):(3 * nS + 1)
                    refmain(i, j) = py(j - nS);
                end
            end
        end
    end

    % Calculate Prediction Equations
    for i = 1:n_mode

        for k = 1:nS
            iIdx = fix(k * intra_angle(i) / 32);

            for l = 1:nS

                if (iFact((i - 1) * nS + l) == 0)

                    predSamples(k, l) = refmain(i, l + iIdx + nS + 1);

                else

                    predSamples(k, l) = fix(double((32 - iFact((i - 1) * nS + l)) * refmain(i, (l + iIdx + nS + 1)) + iFact((i - 1) * nS + l) * refmain(i, (l + iIdx + nS + 2)) + 16) / 32);

                end

            end
        end
        Intra_Angular(i) = {predSamples};
    end

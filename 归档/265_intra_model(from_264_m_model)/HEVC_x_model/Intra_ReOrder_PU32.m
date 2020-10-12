function [img_reor, ModeWiseMat] = Intra_ReOrder_PU32(image_wide, image_high, encoded_pixels, PU)
    % Reorder intra predicted frames for given PU size
    % Inputs:
    %	image_wide 		: Width of the input image
    %	image_high 		: Height of the input image
    % 	encoded_pixels	: Intra Predicted Frames (DC,Planar,Angular 2..34) for Given PU Size
    %	PU				: PU Size
    % Outputs:
    %	img_reor	    : Reordered Frames

    In_Size = size(encoded_pixels);
    img_reor = zeros(In_Size(1, 1), In_Size(1, 2));

    for ss = 1:In_Size(1, 1)
        read_addr = 1;
        for i = 0:(image_high / 64 - 1)
            for j = 0:(image_wide / 64 - 1)

                mb_addr = i * 64 * image_wide + j * 64;

                for k = 0:3

                    switch k
                        case 0
                            horz_off = 0;
                            vert_off = 0;
                        case 1
                            horz_off = 32;
                            vert_off = 0;
                        case 2
                            horz_off = 0;
                            vert_off = 32;
                        case 3
                            horz_off = 32;
                            vert_off = 32;
                    end
                    % If PU < 32, reorder the pixels in each 32x32 PU.
                    if (PU < 32)
                        inp_image = Intra_ReOrder_PU16(encoded_pixels(ss, read_addr:read_addr + 1023), PU);
                    else
                        inp_image = encoded_pixels(ss, read_addr:read_addr + 1023);
                    end

                    yy_addr = mb_addr + vert_off * image_wide + horz_off;
                    r_addr = 1;
                    % writing luma pixels into array
                    for m = 0:31
                        write_addr = yy_addr + m * image_wide + 1;
                        img_reor(ss, write_addr:write_addr + 31) = inp_image(r_addr:r_addr + 31); % encoded_pixels(ss,read_addr:read_addr+31);
                        read_addr = read_addr + 32;
                        r_addr = r_addr + 32;
                    end
                end
            end
        end

        Re_IM = reshape(img_reor(ss, :), 1920, 1024)';

        % Plot Reordered Frames.
        %     figure;
        %     imshow(uint8(Re_IM));
        Mode = ss;

        % fname = sprintf('C:\\Users\\tharun\\Documents\\MATLAB\\Thesis_2_26_16_Circle\\Intra-Images\\IntraCode_Mode%d.jpg', ss);
        fname = sprintf('Intra-Images\\IntraCode_Mode%d.jpg', ss);
        imwrite(uint8(Re_IM), fname);

        ModeWiseMat{ss} = uint8(Re_IM);

    end

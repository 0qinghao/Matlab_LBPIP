function  img_reor = Intra_ReOrder_PU16(encoded_pixels, PU)
% Reorder 4 16x16 intra predicted PU inside the 32x32 block.
% Inputs:
% 	encoded_pixels	: Intra Predicted Frames (DC,Planar,Angular 2..34) for Given PU Size
%	PU				: PU Size
% Outputs:
%	img_reor	    : Reordered Frames

    read_addr = 1;
    for k = 0:3

        switch k
            case 0
                horz_off = 0;
                vert_off = 0;
            case 1
                horz_off = 16;
                vert_off = 0;                      
            case 2
                horz_off = 0;
                vert_off = 16;
            case 3
                horz_off = 16;
                vert_off = 16;
        end
		% If PU < 16, reorder the pixels in each 16x16 PU.
        if(PU < 16)
            inp_image  = Intra_ReOrder_PU8(encoded_pixels(read_addr:read_addr+255), PU);
        else
            inp_image  = encoded_pixels;
        end
        
		yy_addr = vert_off*32 + horz_off;
        r_addr = 1;
    % writing luma pixels into array
        for m=0:15
            write_addr = yy_addr + m*32 + 1;
            img_reor(write_addr:write_addr+15) = inp_image(r_addr:r_addr+15); % encoded_pixels(ss,read_addr:read_addr+15);
            read_addr = read_addr + 16;
            r_addr    = r_addr + 16;            
        end
    end       
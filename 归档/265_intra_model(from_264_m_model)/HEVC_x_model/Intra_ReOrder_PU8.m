function  img_reor = Intra_ReOrder_PU8(encoded_pixels, PU)
% Reorder 4 8x8 intra predicted PU inside the 16x16 block.
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
                horz_off = 8;
                vert_off = 0;                      
            case 2
                horz_off = 0;
                vert_off = 8;
            case 3
                horz_off = 8;
                vert_off = 8;
        end
		% If PU < 8, reorder the pixels in each 8x8 PU.
        if(PU < 8)
            inp_image  = Intra_ReOrder_PU4(encoded_pixels(read_addr:read_addr+63), PU);
        else
            inp_image  = encoded_pixels;
        end
        
        yy_addr = vert_off*16 + horz_off;
        r_addr = 1;
    
        for m=0:7
            write_addr = yy_addr + m*16 + 1;
            img_reor(write_addr:write_addr+7) = inp_image(r_addr:r_addr+7); % encoded_pixels(ss,read_addr:read_addr+15);
            read_addr = read_addr + 8;
            r_addr = r_addr + 8;
        end
    end          
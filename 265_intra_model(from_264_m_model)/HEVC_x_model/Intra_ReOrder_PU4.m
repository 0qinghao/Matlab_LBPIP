function  img_reor = Intra_ReOrder_PU4(encoded_pixels, PU)

% Reorder 4 4x4 intra predicted PU inside the 8x8 block
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
                horz_off = 4;
                vert_off = 0;                      
            case 2
                horz_off = 0;
                vert_off = 4;
            case 3
                horz_off = 4;
                vert_off = 4;
        end

        
            inp_image  = encoded_pixels;
   
        yy_addr = vert_off*8 + horz_off;
        r_addr = 1;
    
        for m=0:3
            write_addr = yy_addr + m*8 + 1;
            img_reor(write_addr:write_addr+3) = inp_image(r_addr:r_addr+3); % encoded_pixels(ss,read_addr:read_addr+15);
            read_addr = read_addr + 4;
            r_addr    = r_addr + 4;
        end
    end
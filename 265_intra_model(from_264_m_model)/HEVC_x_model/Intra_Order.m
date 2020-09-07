function  img_or = Intra_Order(image_wide, image_high, org)
% Order input frame for given CTB size
% Inputs:
%	image_wide : Width of the input image
%	image_high : Height of the input image
% 	org		   : Input Frame
% Outputs:
%	img_or	   : Ordered Frame

% img = reshape(org',1,1920*1080);
img = reshape(org',1,1920*1024);

% Write to File
write_addr = 1;

file_size = image_wide * image_high;

% Order input frame
for i=0:(image_high/64 - 1)
    for j = 0:(image_wide/64 - 1)
        for k = 0:63
            
            read_addr = j*64 + i*image_wide*64 + image_wide*k + 1;
			img_or(write_addr:write_addr+63) = img(read_addr:read_addr+63);
			write_addr = write_addr + 64;

        
        end
    end
end


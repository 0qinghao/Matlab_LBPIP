% clear all;
% close all;
% clc

% Intra Prediction Matlab Model Top Module
% For All PU Sizes and Prediction Modes

 
 % Read the input after first Transform and inverseQuant
 someX = imread ('HEVC_TransformedImage.png');
 
 org = rgb2gray(someX);
 imshow(uint8(org))  
    
 % Determine Size of Image
 [image_high, image_width] = size(org);
 
 % Determine CU and PU sizes.
 CU_Size     = 64;  % CTB Size
 PU          = 4;   % PU Size (4,8,16,32).
 image_high  = fix(image_high/CU_Size)*CU_Size;
 
 % Order Image for 64x64 Size CTB
 img_or = Intra_Order(image_width, image_high, org);
 mb_buf = uint8(img_or);
 
 % Intra Prediction Module
 encoded_pixels = Intra_Prediction_Control(mb_buf,CU_Size,image_width,image_high,PU);
 
 % Reorder Predicted Frames
 img_reor = Intra_ReOrder_PU32(image_width, image_high, encoded_pixels, PU);
 
 disp('Done')
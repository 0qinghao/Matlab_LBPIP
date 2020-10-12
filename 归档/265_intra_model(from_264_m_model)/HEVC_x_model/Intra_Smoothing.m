function  [PF_X, PF_Y]     =   Intra_Smoothing(PU, PX, PY)

% Intra Smoothing Filter
% PU = 4x4      -> Not Available
% PU = 8x8      -> Only Planar, Angular(2,18,34)
% PU = 16x16    -> All modes except DC, Angular(10,26,9,11,25,27)
% PU = 32x32    -> All modex except DC, Angular(10,26)

% Inputs  : Neighboring Pixels
% Outputs : Smoothed Neighboring Pixels

if(PU == 32)
    
    PF_X(1) = PX(1);
    PF_Y(1) = PY(1);
    
    for i =  2:(2*PU)
        PF_Y(i) = uint8(((64-i+1)*PY(1) + (i-1)*PY(2*PU+1) + 32)/64);
        PF_X(i) = uint8(((64-i+1)*PX(1) + (i-1)*PX(2*PU+1) + 32)/64);
    end
    
    PF_Y(2*PU+1)  = PY(2*PU+1);
    PF_X(2*PU+1)  = PX(2*PU+1); 
    
else
    
    PF_X(1) = uint8(((PX(2) + 2*PX(1) + PY(2) + 2))/4);
    PF_Y(1) = uint8(((PX(2) + 2*PX(1) + PY(2) + 2))/4);
    
    for i =  2:(2*PU)
        PF_Y(i) = uint8((PY(i-1) + 2*PY(i) + PY(i+1) + 2)/4);   
        PF_X(i) = uint8((PX(i-1) + 2*PX(i) + PX(i+1) + 2)/4);
    end
    
    PF_Y(2*PU+1)  = PY(PU+1);
    PF_X(2*PU+1)  = PX(PU+1); 
    
end

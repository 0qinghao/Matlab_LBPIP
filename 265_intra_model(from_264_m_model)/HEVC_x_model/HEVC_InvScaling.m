function [ ReconstructMatx ] = HEVC_InvScaling(InvQuant, M_Mat, BitDepth_B)
                
    DTrans = M_Mat';
    INvstage1 = DTrans * InvQuant;
    
    SIT1 = 1/2^7;
    
    INvstage2 = INvstage1 * SIT1;
    
    Invstage3 = INvstage2 * M_Mat;
    
    SIT2 = 1/(2^(20-BitDepth_B));
    
    RoundedFinal = (Invstage3 * SIT2);
    
    ReconstructMatx = round (RoundedFinal);
%     ReconstructMatx =  (RoundedFinal);
end



function  Intra_Planar =   Planar_Model(PU, PX, PY)

% Intra Planar Prediction
% Inputs :
%   PU = Prediction Unit Size
%   PX = Left Neighboring Pixels
%   PY = Top  Neighboring Pixels

% Output:
%   Intra_Planar : Planar Predicted Output PU

for i=0:PU-1
    for j=0:PU-1
      
        Intra_Planar(i+1,j+1) = uint8(((PU - 1 - i)*PY(j+2) + (i+1)*PX(PU) + (PU - 1 - j)*PX(i+2) + (j+1)*PY(PU) + PU)/(2^(log2(PU)+1)));        
        
    end
end
function [ M_Mat, Quant_Mat ] = GetTables( TempSize )
        if(TempSize== 4)
            M_Mat = 1;
            Quant_Mat = 1;
        elseif(TempSize== 8)
            M_Mat = 2;
            Quant_Mat = 2;
        elseif(TempSize== 16)
            M_Mat = 3;
            Quant_Mat = 3;
        elseif(TempSize== 32)
            M_Mat = 4;
            Quant_Mat = 4;
        else
            disp('Unsupported matrix Size');
        end
end


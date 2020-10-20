function [Quantization] = HEVC_Quantization(ScaledMatrix, Quant4_Mat, QP, B)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    Usize = size(ScaledMatrix);
    NVal = Usize(1);

    M = log2 (NVal);

    Temp = rem(QP, 6);
    switch (Temp)
        case 0
            FQP = 26214;
        case 1
            FQP = 23302;
        case 2
            FQP = 20560;
        case 3
            FQP = 18396;
        case 4
            FQP = 16384;
        case 5
            FQP = 14564;
    end

    QPby6 = QP / 6;
    Shift2 = 29 - M - B;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         QStep = 2 ^ (1/6 * (QP - 4));
    %
    %         Quantoo = (ScaledMatrix ./ 2 ^ (1/6 * (QP - 4)));
    %         Quantiged = round (ScaledMatrix ./ 2 ^ (1/6 * (QP - 4)))

    %Quanti = (2 ^ (1/6))^ (QP-4);
    %Quantize = ScaledMatrix ./Quanti
    %teppp = (((abs (ScaledMatrix) .* FQP .*  (16 ./ Quant4_Mat) ) ./ 2 ^ QPby6)./2 ^ Shift2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Quantization = round(sign (ScaledMatrix) .* (((abs (ScaledMatrix) .* FQP .* (16 ./ Quant4_Mat)) ./ 2^QPby6) ./ 2^Shift2));

    % QuantbyQstep = round(((ScaledMatrix .* 2^14 .* (16 ./ Quant4_Mat)) ./ 2 ^ Shift2)./ 2 ^ QPby6)

end

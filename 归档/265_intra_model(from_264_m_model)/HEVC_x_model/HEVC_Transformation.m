function [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, D, U)

    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    % U: 像素数据
    % D: M_Mat

    U = double(U);
    Usize = size(U);
    NVal = Usize(1);

    M = log2 (NVal);

    %-------------------------------------------------%

    Transstage1 = (D * U); % 18 bits for 4*4
    TransforMatrix = Transstage1 * (2^ - (BitDepth_B + M - 9)); % 17 bits for 4*4
    xxxx = fix(TransforMatrix);
    Scaled = xxxx * D';
    % Scaled = TransforMatrix * D';                           % 26 bits for 4*4
    ScaledMatrix = Scaled * (2^ - (M + 6));

    %-------------------------------------------------%

    NumBitsTrans1 = 2 * BitDepth_B + M;
    NumBitsScaled = 16 + BitDepth_B + M;

end

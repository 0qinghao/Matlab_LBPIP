% 这个工程有问题，在预测的时候，根本没有做重建，用精确值去做下一个块的预测，离谱！难道是前后这个莫名其妙的变化、编码起了作用？这我就看不懂了。

close all
clc
clear

% format loose

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HEVC Tables
%%%%%%%%%%% 4, 8, 16, 32 sizes

M_Mat = cell(4, 1);
Quant_Mat = cell(4, 1);

M4_Mat = [64, 64, 64, 64; 83, 36, -36, -83; 64, -64, -64, 64; 36, -83, 83, -36];

M8_Mat = [64, 64, 64, 64, 64, 64, 64, 64; ...
        89, 75, 50, 18, -18, -50, -75, -89; ...
        83, 36, -36, -83, -83, -36, 36, 83; ...
        75, -18, -89, -50, 50, 89, 18, -75; ...
        64, -64, -64, 64, 64, -64, -64, 64; ...
        50, -89, 18, 75, -75, -18, 89, -50; ...
        36, -83, 83, -36, -36, 83, -83, 36; ...
        18, -50, 75, -89, 89, -75, 50, -18];

M16_Mat = [64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64; ...
            90, 87, 80, 70, 57, 43, 25, 9, -9, -25, -43, -57, -70, -80, -87, -90; ...
            89, 75, 50, 18, -18, -50, -75, -89, -89, -75, -50, -18, 18, 50, 75, 89; ...
            87, 57, 9, -43, -80, -90, -70, -25, 25, 70, 90, 80, 43, -9, -57, -87; ...
            83, 36, -36, -83, -83, -36, 36, 83, 83, 36, -36, -83, -83, -36, 36, 83; ...
            80, 9, -70, -87, -25, 57, 90, 43, -43, -90, -57, 25, 87, 70, -9, -80; ...
            75, -18, -89, -50, 50, 89, 18, -75, -75, 18, 89, 50, -50, -89, -18, 75; ...
            70, -43, -87, 9, 90, 25, -80, -57, 57, 80, -25, -90, -9, 87, 43, -70; ...
            64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64; ...
            57, -80, -25, 90, -9, -87, 43, 70, -70, -43, 87, 9, -90, 25, 80, -57; ...
            50, -89, 18, 75, -75, -18, 89, -50, -50, 89, -18, -75, 75, 18, -89, 50; ...
            43, -90, 57, 25, -87, 70, 9, -80, 80, -9, -70, 87, -25, -57, 90, -43; ...
            36, -83, 83, -36, -36, 83, -83, 36, 36, -83, 83, -36, -36, 83, -83, 36; ...
            25, -70, 90, -80, 43, 9, -57, 87, -87, 57, -9, -43, 80, -90, 70, -25; ...
            18, -50, 75, -89, 89, -75, 50, -18, -18, 50, -75, 89, -89, 75, -50, 18; ...
            9, -25, 43, -57, 70, -80, 87, -90, 90, -87, 80, -70, 57, -43, 25, -9];

M32_Mat = [64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64; ...
            90, 90, 88, 85, 82, 78, 73, 67, 61, 54, 46, 38, 31, 22, 13, 4, -4, -13, -22, -31, -38, -46, -54, -61, -67, -73, -78, -82, -85, -88, -90, -90; ...
            90, 87, 80, 70, 57, 43, 25, 9, -9, -25, -43, -57, -70, -80, -87, -90, -90, -87, -80, -70, -57, -43, -25, -9, 9, 25, 43, 57, 70, 80, 87, 90; ...
            90, 82, 67, 46, 22, -4, -31, -54, -73, -85, -90, -88, -78, -61, -38, -13, 13, 38, 61, 78, 88, 90, 85, 73, 54, 31, 4, -22, -46, -67, -82, -90; ...
            89, 75, 50, 18, -18, -50, -75, -89, -89, -75, -50, -18, 18, 50, 75, 89, 89, 75, 50, 18, -18, -50, -75, -89, -89, -75, -50, -18, 18, 50, 75, 89; ...
            88, 67, 31, -13, -54, -82, -90, -78, -46, -4, 38, 73, 90, 85, 61, 22, -22, -61, -85, -90, -73, -38, 4, 46, 78, 90, 82, 54, 13, -31, -67, -88; ...
            87, 57, 9, -43, -80, -90, -70, -25, 25, 70, 90, 80, 43, -9, -57, -87, -87, -57, -9, 43, 80, 90, 70, 25, -25, -70, -90, -80, -43, 9, 57, 87; ...
            85, 46, -13, -67, -90, -73, -22, 38, 82, 88, 54, -4, -61, -90, -78, -31, 31, 78, 90, 61, 4, -54, -88, -82, -38, 22, 73, 90, 67, 13, -46, -85; ...
            83, 36, -36, -83, -83, -36, 36, 83, 83, 36, -36, -83, -83, -36, 36, 83, 83, 36, -36, -83, -83, -36, 36, 83, 83, 36, -36, -83, -83, -36, 36, 83; ...
            82, 22, -54, -90, -61, 13, 78, 85, 31, -46, -90, -67, 4, 73, 88, 38, -38, -88, -73, -4, 67, 90, 46, -31, -85, -78, -13, 61, 90, 54, -22, -82; ...
            80, 9, -70, -87, -25, 57, 90, 43, -43, -90, -57, 25, 87, 70, -9, -80, -80, -9, 70, 87, 25, -57, -90, -43, 43, 90, 57, -25, -87, -70, 9, 80; ...
            78, -4, -82, -73, 13, 85, 67, -22, -88, -61, 31, 90, 54, -38, -90, -46, 46, 90, 38, -54, -90, -31, 61, 88, 22, -67, -85, -13, 73, 82, 4, -78; ...
            75, -18, -89, -50, 50, 89, 18, -75, -75, 18, 89, 50, -50, -89, -18, 75, 75, -18, -89, -50, 50, 89, 18, -75, -75, 18, 89, 50, -50, -89, -18, 75; ...
            73, -31, -90, -22, 78, 67, -38, -90, -13, 82, 61, -46, -88, -4, 85, 54, -54, -85, 4, 88, 46, -61, -82, 13, 90, 38, -67, -78, 22, 90, 31, -73; ...
            70, -43, -87, 9, 90, 25, -80, -57, 57, 80, -25, -90, -9, 87, 43, -70, -70, 43, 87, -9, -90, -25, 80, 57, -57, -80, 25, 90, 9, -87, -43, 70; ...
            67, -54, -78, 38, 85, -22, -90, 4, 90, 13, -88, -31, 82, 46, -73, -61, 61, 73, -46, -82, 31, 88, -13, -90, -4, 90, 22, -85, -38, 78, 54, -67; ...
            64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64, 64, -64, -64, 64; ...
            61, -73, -46, 82, 31, -88, -13, 90, -4, -90, 22, 85, -38, -78, 54, 67, -67, -54, 78, 38, -85, -22, 90, 4, -90, 13, 88, -31, -82, 46, 73, -61; ...
            57, -80, -25, 90, -9, -87, 43, 70, -70, -43, 87, 9, -90, 25, 80, -57, -57, 80, 25, -90, 9, 87, -43, -70, 70, 43, -87, -9, 90, -25, -80, 57; ...
            54, -85, -4, 88, -46, -61, 82, 13, -90, 38, 67, -78, -22, 90, -31, -73, 73, 31, -90, 22, 78, -67, -38, 90, -13, -82, 61, 46, -88, 4, 85, -54; ...
            50, -89, 18, 75, -75, -18, 89, -50, -50, 89, -18, -75, 75, 18, -89, 50, 50, -89, 18, 75, -75, -18, 89, -50, -50, 89, -18, -75, 75, 18, -89, 50; ...
            46, -90, 38, 54, -90, 31, 61, -88, 22, 67, -85, 13, 73, -82, 4, 78, -78, -4, 82, -73, -13, 85, -67, -22, 88, -61, -31, 90, -54, -38, 90, -46; ...
            43, -90, 57, 25, -87, 70, 9, -80, 80, -9, -70, 87, -25, -57, 90, -43, -43, 90, -57, -25, 87, -70, -9, 80, -80, 9, 70, -87, 25, 57, -90, 43; ...
            38, -88, 73, -4, -67, 90, -46, -31, 85, -78, 13, 61, -90, 54, 22, -82, 82, -22, -54, 90, -61, -13, 78, -85, 31, 46, -90, 67, 4, -73, 88, -38; ...
            36, -83, 83, -36, -36, 83, -83, 36, 36, -83, 83, -36, -36, 83, -83, 36, 36, -83, 83, -36, -36, 83, -83, 36, 36, -83, 83, -36, -36, 83, -83, 36; ...
            31, -78, 90, -61, 4, 54, -88, 82, -38, -22, 73, -90, 67, -13, -46, 85, -85, 46, 13, -67, 90, -73, 22, 38, -82, 88, -54, -4, 61, -90, 78, -31; ...
            25, -70, 90, -80, 43, 9, -57, 87, -87, 57, -9, -43, 80, -90, 70, -25, -25, 70, -90, 80, -43, -9, 57, -87, 87, -57, 9, 43, -80, 90, -70, 25; ...
            22, -61, 85, -90, 73, -38, -4, 46, -78, 90, -82, 54, -13, -31, 67, -88, 88, -67, 31, 13, -54, 82, -90, 78, -46, 4, 38, -73, 90, -85, 61, -22; ...
            18, -50, 75, -89, 89, -75, 50, -18, -18, 50, -75, 89, -89, 75, -50, 18, 18, -50, 75, -89, 89, -75, 50, -18, -18, 50, -75, 89, -89, 75, -50, 18; ...
            13, -38, 61, -78, 88, -90, 85, -73, 54, -31, 4, 22, -46, 67, -82, 90, -90, 82, -67, 46, -22, -4, 31, -54, 73, -85, 90, -88, 78, -61, 38, -13; ...
            9, -25, 43, -57, 70, -80, 87, -90, 90, -87, 80, -70, 57, -43, 25, -9, -9, 25, -43, 57, -70, 80, -87, 90, -90, 87, -80, 70, -57, 43, -25, 9; ...
            4, -13, 22, -31, 38, -46, 54, -61, 67, -73, 78, -82, 85, -88, 90, -90, 90, -90, 88, -85, 82, -78, 73, -67, 61, -54, 46, -38, 31, -22, 13, -4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HEVC Quantization Tables
%%%%%%%%%%% 4, 8, 16, 32 sizes

Quant4_Mat = [16, 16, 16, 16; 16, 16, 16, 16; 16, 16, 16, 16; 16, 16, 16, 16];

Quant8_Mat = [16, 16, 16, 16, 17, 18, 21, 24; ...
            16, 16, 16, 16, 17, 19, 22, 25; ...
            16, 16, 17, 18, 20, 22, 25, 29; ...
            16, 16, 18, 21, 24, 27, 31, 36; ...
            17, 17, 20, 24, 30, 35, 41, 47; ...
            18, 19, 22, 27, 35, 44, 54, 65; ...
            21, 22, 25, 31, 41, 54, 70, 88; ...
            24, 25, 29, 36, 47, 65, 88, 115];

Quant16_Mat = [16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115; ...
                16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115];

Quant32_Mat = [16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115; ...
                16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115; ...
                16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115; ...
                16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24, 16, 16, 16, 16, 17, 18, 21, 24; ...
                16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25, 16, 16, 16, 16, 17, 19, 22, 25; ...
                16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29, 16, 16, 17, 18, 20, 22, 25, 29; ...
                16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36, 16, 16, 18, 21, 24, 27, 31, 36; ...
                17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47, 17, 17, 20, 24, 30, 35, 41, 47; ...
                18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65, 18, 19, 22, 27, 35, 44, 54, 65; ...
                21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88, 21, 22, 25, 31, 41, 54, 70, 88; ...
                24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115, 24, 25, 29, 36, 47, 65, 88, 115];

Image16_Mat = [106, 101, 95, 90, 86, 80, 75, 70, 106, 101, 95, 90, 86, 80, 75, 70; ...
                105, 99, 93, 88, 84, 78, 73, 67, 105, 99, 93, 88, 84, 78, 73, 67; ...
                103, 97, 91, 86, 82, 75, 70, 64, 103, 97, 91, 86, 82, 75, 70, 64; ...
                100, 94, 88, 83, 79, 72, 65, 60, 100, 94, 88, 83, 79, 72, 65, 60; ...
                99, 92, 86, 82, 76, 68, 61, 57, 99, 92, 86, 82, 76, 68, 61, 57; ...
                97, 91, 85, 79, 73, 65, 58, 54, 97, 91, 85, 79, 73, 65, 58, 54; ...
                95, 89, 82, 76, 70, 61, 55, 51, 95, 89, 82, 76, 70, 61, 55, 51; ...
                94, 88, 82, 74, 66, 59, 53, 49, 94, 88, 82, 74, 66, 59, 53, 49; ...
                106, 101, 95, 90, 86, 80, 75, 70, 106, 101, 95, 90, 86, 80, 75, 70; ...
                105, 99, 93, 88, 84, 78, 73, 67, 105, 99, 93, 88, 84, 78, 73, 67; ...
                103, 97, 91, 86, 82, 75, 70, 64, 103, 97, 91, 86, 82, 75, 70, 64; ...
                100, 94, 88, 83, 79, 72, 65, 60, 100, 94, 88, 83, 79, 72, 65, 60; ...
                99, 92, 86, 82, 76, 68, 61, 57, 99, 92, 86, 82, 76, 68, 61, 57; ...
                97, 91, 85, 79, 73, 65, 58, 54, 97, 91, 85, 79, 73, 65, 58, 54; ...
                95, 89, 82, 76, 70, 61, 55, 51, 95, 89, 82, 76, 70, 61, 55, 51; ...
                94, 88, 82, 74, 66, 59, 53, 49, 94, 88, 82, 74, 66, 59, 53, 49];

M_Mat{1} = M4_Mat;
M_Mat{2} = M8_Mat;
M_Mat{3} = M16_Mat;
M_Mat{4} = M32_Mat;

Quant_Mat{1} = Quant4_Mat;
Quant_Mat{2} = Quant8_Mat;
Quant_Mat{3} = Quant16_Mat;
Quant_Mat{4} = Quant32_Mat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Read inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prompt = 'Enter QP value as 0 to 51   ';
% QPEntered = input(prompt);

% prompt = 'Enter the Value of blocksize i.e. 4 or 8 or 16 or 32:   ';
% blocksize = input(prompt);

ReadInput = imread ('Lena_1920_1080.png'); % RGB image
I = imresize(ReadInput, [1024 1920]);

Y = rgb2gray(I);
% figure; imshow(Y);%impixelinfo

orig_img = Y;
% figure(1); imshow(orig_img);title('Original Image');  %impixelinfo;

Fourby4_org = orig_img(1:4, 1:4);
Eightby8_org = orig_img(1:8, 1:8);
Sixteenby16_org = orig_img(1:16, 1:16);

CurrentSize = size(orig_img);
% MainSize1D = CurrentSize(1);

% Hard coded to skip prompting
% 定死 位深、QP、块大小
BitDepth_B = 8;
QPEntered = 4;
blocksize = 16;

rows = CurrentSize(1);
cols = CurrentSize(2);

for row = 1:blocksize:rows
    % if mod(row, 2) == 1
    % 看不懂这个 if，row mod 2 肯定是 1 嘛
    for col = 1:blocksize:cols
        % take a block of the image:
        tempvar = orig_img(row:row + blocksize - 1, col:col + blocksize - 1);
        TransTempSize = size(tempvar);
        [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));
        [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
        TransforMatrix_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = TransforMatrix;
        ScaledMatrix_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = ScaledMatrix;

        [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
        Quantization_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = Quantization;

        [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
        InvQuant_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = InvQuant;

        [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
        ITSQ_Mat_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = ITSQ_Mat;

        pictoshow = uint8(ITSQ_Mat);
        HEVC_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = pictoshow;
    end
    % else
    %     display 1
    %     for col = 1:blocksize:cols
    %         if mod(col, 2) == 1
    %             % take a block of the image:
    %             tempvar = orig_img(row:row + blocksize - 1, col:col + blocksize - 1);
    %             TransTempSize = size(tempvar);
    %             [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));
    %             [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
    %             TransforMatrix_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = TransforMatrix;
    %             ScaledMatrix_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = ScaledMatrix;

    %             [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
    %             Quantization_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = Quantization;

    %             [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
    %             InvQuant_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = InvQuant;

    %             [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
    %             ITSQ_Mat_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = ITSQ_Mat;

    %             pictoshow = uint8(ITSQ_Mat);
    %             HEVC_T0_img(row:row + blocksize - 1, col:col + blocksize - 1) = pictoshow;
    %         else
    %             rowadd = row;
    %             temprow = 0;
    %             for kk = 1:2
    %                 tempcol = 0;
    %                 coladd = col;
    %                 for bb = 1:2
    %                     innerBlockSize = blocksize / 2;
    %                     tempvar = orig_img(row + 16 * temprow:rowadd + innerBlockSize - 1, col + 16 * tempcol:coladd + innerBlockSize - 1);
    %                     TransTempSize = size(tempvar);
    %                     [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));
    %                     [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
    %                     TransforMatrix_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = TransforMatrix;
    %                     ScaledMatrix_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = ScaledMatrix;

    %                     [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
    %                     Quantization_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = Quantization;

    %                     [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
    %                     InvQuant_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = Quantization;

    %                     [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
    %                     ITSQ_Mat_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = ITSQ_Mat;

    %                     pictoshow = uint8(ITSQ_Mat);
    %                     HEVC_T0_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = pictoshow;
    %                     coladd = col + 16;
    %                     tempcol = tempcol + 1;
    %                 end % end of bb
    %                 rowadd = row + 16;
    %                 temprow = temprow + 1;

    %             end % end of kk

    %         end % end of else

    %     end %end of cols
    % end % end of else

end %end of main row

% figure(2); imshow(HEVC_T0_img); title('Reconstructed T0 image'); %impixelinfo;
imwrite(HEVC_T0_img, 'HEVC_T0_img.png')

Quantization_T0_4 = Quantization_T0_img(1:4, 1:4);
Quantization_T0_8 = Quantization_T0_img(1:8, 1:8);
Quantization_T0_16 = Quantization_T0_img(1:16, 1:16);

ITSQ_Mat_T0_4 = ITSQ_Mat_T0_img(1:4, 1:4);
ITSQ_Mat_T0_8 = ITSQ_Mat_T0_img(1:8, 1:8);
ITSQ_Mat_T0_16 = ITSQ_Mat_T0_img(1:16, 1:16);

% ？？？这上面在做什么
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        T0 ITSQ completed
%          This is the input for Intra Prediction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Intra Prediction in Progress...Please wait');

org = HEVC_T0_img;
% figure(3); imshow(uint8(org)); title('Intra Input Image');

% Determine Size of Video
[image_high, image_width] = size(org);

% Determine CU and PU sizes.
CU_Size = 64; % CTB Size
PU = 16; % PU Size (4,8,16,32).
image_high = fix(image_high / CU_Size) * CU_Size;

% Order Image for 64x64 Size
img_or = Intra_Order(image_width, image_high, org);
mb_buf = uint8(img_or);

% Intra Prediction Module
encoded_pixels = Intra_Prediction_Control(mb_buf, CU_Size, image_width, image_high, PU);

%  prompt = 'Enter Prediction Mode 0 to 33   ';
%  ModeEntered = input(prompt);

ModeEntered = 2;

% Reorder Predicted Frames
[img_reor, IntraPerformed] = Intra_ReOrder_PU32(image_width, image_high, encoded_pixels, PU);

T0_Intra_Out = IntraPerformed{ModeEntered};
Intra_Out_T0_4 = T0_Intra_Out(1:4, 1:4)
Intra_Out_T0_8 = T0_Intra_Out(1:8, 1:8)
Intra_Out_T0_16 = T0_Intra_Out(1:16, 1:16)

% figure(4); imshow(T0_Intra_Out); title('T0 Intra out Image'); %impixelinfo

%take all intra pictures

% Mode 0 to mode 3
% figure(5);
% subplot(2, 2, 1);
% imshow(IntraPerformed{1}); %impixelinfo;
% title('Mode 0');

% subplot(2, 2, 2);
% imshow(IntraPerformed{2}); %impixelinfo;
% title('Mode 1');

% subplot(2, 2, 3);
% imshow(IntraPerformed{3}); %impixelinfo;
% title('Mode 2');

% subplot(2, 2, 4);
% imshow(IntraPerformed{4}); %impixelinfo;
% title('Mode 3');

% % Mode 4 to mode 7
% figure(6);

% subplot(2, 2, 1);
% imshow(IntraPerformed{5}); %impixelinfo;
% title('Mode 4');

% subplot(2, 2, 2);
% imshow(IntraPerformed{6}); %impixelinfo;
% title('Mode 5');

% subplot(2, 2, 3);
% imshow(IntraPerformed{7}); %impixelinfo;
% title('Mode 6');

% subplot(2, 2, 4);
% imshow(IntraPerformed{8}); %impixelinfo;
% title('Mode 7');

% % Mode 8 to mode 11
% figure(7);

% subplot(2, 2, 1);
% imshow(IntraPerformed{9}); %impixelinfo;
% title('Mode 8');

% subplot(2, 2, 2);
% imshow(IntraPerformed{10}); %impixelinfo;
% title('Mode 9');

% subplot(2, 2, 3);
% imshow(IntraPerformed{11}); %impixelinfo;
% title('Mode 10');

% subplot(2, 2, 4);
% imshow(IntraPerformed{12}); %impixelinfo;
% title('Mode 11');

% % Mode 12 to mode 15
% figure(8);

% subplot(2, 2, 1);
% imshow(IntraPerformed{13}); %impixelinfo;
% title('Mode 12');

% subplot(2, 2, 2);
% imshow(IntraPerformed{14}); %impixelinfo;
% title('Mode 13');

% subplot(2, 2, 3);
% imshow(IntraPerformed{15}); %impixelinfo;
% title('Mode 14');

% subplot(2, 2, 4);
% imshow(IntraPerformed{16}); %impixelinfo;
% title('Mode 15');

% % Mode 16 to mode 19
% figure(9);

% subplot(2, 2, 1);
% imshow(IntraPerformed{17}); %impixelinfo;
% title('Mode 16');

% subplot(2, 2, 2);
% imshow(IntraPerformed{18}); %impixelinfo;
% title('Mode 17');

% subplot(2, 2, 3);
% imshow(IntraPerformed{19}); %impixelinfo;
% title('Mode 18');

% subplot(2, 2, 4);
% imshow(IntraPerformed{20}); %impixelinfo;
% title('Mode 19');

% % Mode 20 to mode 23
% figure(10);

% subplot(2, 2, 1);
% imshow(IntraPerformed{21}); %impixelinfo;
% title('Mode 20');

% subplot(2, 2, 2);
% imshow(IntraPerformed{22}); %impixelinfo;
% title('Mode 21');

% subplot(2, 2, 3);
% imshow(IntraPerformed{23}); %impixelinfo;
% title('Mode 22');

% subplot(2, 2, 4);
% imshow(IntraPerformed{24}); %impixelinfo;
% title('Mode 23');

% % Mode 23 to mode 27
% figure(11);

% subplot(2, 2, 1);
% imshow(IntraPerformed{25}); %impixelinfo;
% title('Mode 24');

% subplot(2, 2, 2);
% imshow(IntraPerformed{26}); %impixelinfo;
% title('Mode 25');

% subplot(2, 2, 3);
% imshow(IntraPerformed{27}); %impixelinfo;
% title('Mode 26');

% subplot(2, 2, 4);
% imshow(IntraPerformed{28}); %impixelinfo;
% title('Mode 27');

% % Mode 28 to mode 31
% figure(12);

% subplot(2, 2, 1);
% imshow(IntraPerformed{29}); %impixelinfo;
% title('Mode 28');

% subplot(2, 2, 2);
% imshow(IntraPerformed{30}); %impixelinfo;
% title('Mode 29');

% subplot(2, 2, 3);
% imshow(IntraPerformed{31}); %impixelinfo;
% title('Mode 30');

% subplot(2, 2, 4);
% imshow(IntraPerformed{32}); %impixelinfo;
% title('Mode 31');

% % Mode 32 to mode 34
% figure(13);

% subplot(2, 2, 1);
% imshow(IntraPerformed{33}); %impixelinfo;
% title('Mode 32');

% subplot(2, 2, 2);
% imshow(IntraPerformed{34}); %impixelinfo;
% title('Mode 33');

% subplot(2, 2, 3);
% imshow(IntraPerformed{35}); %impixelinfo;
% title('Mode 34');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Intra Completed and result in IntraPerformed
%      Move to Residual and continue second cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spacevar = sprintf('\n \n');
disp(spacevar);
disp('Intra Prediction completed');

Residual_img = orig_img - uint8(T0_Intra_Out);

Residual_4 = Residual_img(1:4, 1:4)
Residual_8 = Residual_img(1:8, 1:8)
Residual_16 = Residual_img(1:16, 1:16)

% figure(14); imshow(Residual_img); title('Residual Image'); %impixelinfo

CurrentSize = size(Residual_img);
MainSize1D = CurrentSize(1);

rows = CurrentSize(1);
cols = CurrentSize(2);

for row = 1:blocksize:rows
    if mod(row, 2) == 1
        for col = 1:blocksize:cols
            % take a block of the image:
            tempvar = Residual_img(row:row + blocksize - 1, col:col + blocksize - 1);
            TransTempSize = size(tempvar);
            [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));

            [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
            TransforMatrix_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = TransforMatrix;
            ScaledMatrix_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = ScaledMatrix;

            [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
            Quantization_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = Quantization;

            [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
            InvQuant_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = InvQuant;

            [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
            ITSQ_Mat_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = ITSQ_Mat;

            pictoshow = uint8(ITSQ_Mat);
            HEVC_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = pictoshow;
        end
    else
        for col = 1:blocksize:cols
            if mod(col, 2) == 1
                % take a block of the image:
                tempvar = Residual_img(row:row + blocksize - 1, col:col + blocksize - 1);
                TransTempSize = size(tempvar);
                [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));
                [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
                TransforMatrix_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = TransforMatrix;
                ScaledMatrix_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = ScaledMatrix;

                [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
                Quantization_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = Quantization;

                [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
                InvQuant_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = InvQuant;

                [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
                ITSQ_Mat_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = ITSQ_Mat;

                pictoshow = uint8(ITSQ_Mat);

                HEVC_T1_img(row:row + blocksize - 1, col:col + blocksize - 1) = pictoshow;
            else
                rowadd = row;
                temprow = 0;
                for kk = 1:2
                    tempcol = 0;
                    coladd = col;
                    for bb = 1:2
                        innerBlockSize = blocksize / 2;
                        tempvar = Residual_img(row + 16 * temprow:rowadd + innerBlockSize - 1, col + 16 * tempcol:coladd + innerBlockSize - 1);
                        TransTempSize = size(tempvar);
                        [M_MatIndex, Quant_MatIndex] = GetTables(TransTempSize(1));
                        [Transstage1, TransforMatrix, Scaled, ScaledMatrix] = HEVC_Transformation(BitDepth_B, M_Mat{M_MatIndex}, tempvar);
                        TransforMatrix_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = TransforMatrix;
                        ScaledMatrix_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = ScaledMatrix;

                        [Quantization] = HEVC_Quantization(ScaledMatrix, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
                        Quantization_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = Quantization;

                        [InvQuant] = HEVC_InvQuant(Quantization, Quant_Mat{Quant_MatIndex}, QPEntered, BitDepth_B);
                        InvQuant_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = Quantization;

                        [ITSQ_Mat] = HEVC_InvScaling(InvQuant, M_Mat{M_MatIndex}, BitDepth_B);
                        ITSQ_Mat_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = ITSQ_Mat;

                        pictoshow = uint8(ITSQ_Mat);

                        HEVC_T1_img(row + 16 * temprow:rowadd + blackk - 1, col + 16 * tempcol:coladd + blackk - 1) = pictoshow;
                        coladd = col + 16;
                        tempcol = tempcol + 1;
                    end % end of bb
                    rowadd = row + 16;
                    temprow = temprow + 1;

                end % end of kk

            end % end of else

        end %end of cols

    end % end of else

end %end of main row

% figure(15); imshow(HEVC_T1_img); title('Reconstructed T1 image'); %impixelinfo;
% imwrite(HEVC_T1_img, 'HEVC_T1_img.png');

Quantization_T1_4 = Quantization_T1_img(1:4, 1:4)
Quantization_T1_8 = Quantization_T1_img(1:8, 1:8)
Quantization_T1_16 = Quantization_T1_img(1:16, 1:16)

ITSQ_Mat_T1_4 = ITSQ_Mat_T1_img(1:4, 1:4)
ITSQ_Mat_T1_8 = ITSQ_Mat_T1_img(1:8, 1:8)
ITSQ_Mat_T1_16 = ITSQ_Mat_T1_img(1:16, 1:16)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        T1 ITSQ completed
%   This is the output that can be added with Intra Prediction
%  Add Intra to transfromed residual to get total
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FinalImage = HEVC_T1_img + uint8(T0_Intra_Out);
FinalImage_4 = FinalImage(1:4, 1:4)
FinalImage_8 = FinalImage(1:8, 1:8)
FinalImage_16 = FinalImage(1:16, 1:16)

% figure(16); imshow(FinalImage); title('HEVC Final Image'); %impixelinfo;
imwrite(FinalImage, 'HEVC_FinalImage.png');

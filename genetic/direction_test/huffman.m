function out = huffman(fid, array, prev, DCcode, ACcode)
    switch numel(array)
        case 16
            zigZagOrder = [1 2 5 9 6 3 4 7 10 13 14 11 8 12 15 16];
        case 64
            zigZagOrder = [1	2	9	17	10	3	4	11	18	25	33	26	19	12	5	6	13	20	27	34	41	49	42	35	28	21	14	7	8	15	22	29	36	43	50	57	58	51	44	37	30	23	16	24	31	38	45	52	59	60	53	46	39	32	40	47	54	61	62	55	48	56	63	64];
    end
    global DC_matrix;
    global AC_matrix;

    % global cnt_code;

    % The DC portion
    temp2 = array(1) - prev;
    temp = temp2;
    if temp < 0
        temp = -temp;
        temp2 = temp2 - 1;
    end
    nbits = 0;
    while temp ~= 0
        nbits = nbits + 1;
        temp = bitshift(temp, -1);
    end

    bufferIt(fid, DC_matrix(DCcode, nbits + 1, 1), DC_matrix(DCcode, nbits + 1, 2));

    if nbits ~= 0
        bufferIt(fid, temp2, nbits);
    end

    % The AC portion

    r = 0;

    for k = 2:numel(array)
        temp = array(zigZagOrder(k));
        if temp == 0
            r = r + 1;
        else
            while r > 15
                % 注意查码字的时候matlab里面ACmatrix的结构，E/系列只有15个
                bufferIt(fid, AC_matrix(ACcode, hex2dec('F0') + 1, 1), AC_matrix(ACcode, hex2dec('F0') + 1, 2));
                % cnt_code(ACcode,hex2dec('F0')+1) = cnt_code(ACcode,hex2dec('F0')+1) + 1;
                r = r - 16;
            end
            temp2 = temp;
            if temp < 0
                temp = -temp;
                temp2 = temp2 - 1;
            end
            nbits = 1;
            temp = bitshift(temp, -1);
            while temp ~= 0
                nbits = nbits + 1;
                temp = bitshift(temp, -1);
            end
            i = bitshift(r, 4) + nbits;
            bufferIt(fid, AC_matrix(ACcode, i + 1, 1), AC_matrix(ACcode, i + 1, 2));
            % cnt_code(ACcode,i+1) = cnt_code(ACcode,i+1) + 1;
            bufferIt(fid, temp2, nbits);

            r = 0;
        end
    end

    if r > 0
        bufferIt(fid, AC_matrix(ACcode, 1, 1), AC_matrix(ACcode, 1, 2));
        % cnt_code(ACcode,1) = cnt_code(ACcode,1) + 1;
    end

    out = array(1);

end

function bufferIt(fid, code, size)
    global bufferPutBits;
    global bufferPutBuffer;

    if code < 0
        code = (2^32) + code;
    end
    PutBuffer = code;
    PutBits = bufferPutBits;

    temp = bitshift(1, size) - 1;

    PutBuffer = bitand(PutBuffer, temp);
    PutBits = PutBits + size;
    PutBuffer = bitshift(PutBuffer, 24 - PutBits);
    PutBuffer = bitor(PutBuffer, bufferPutBuffer);

    while PutBits >= 8
        c = bitand(bitshift(PutBuffer, -16), hex2dec('FF'));
        fwrite(fid, c);

        if c == hex2dec('FF')
            fwrite(fid, 0);
        end
        %         PutBuffer = bitshift(PutBuffer, 8);
        PutBuffer = bitand(bitshift(1, 24) - 1, bitshift(PutBuffer, 8));

        PutBits = PutBits - 8;
    end
    bufferPutBuffer = PutBuffer;
    bufferPutBits = PutBits;

end

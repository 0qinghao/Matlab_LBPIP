function huffman(fid, array)
    ACcode = 1;
    DCcode = 1;

    global DC_matrix;
    global AC_matrix;

    r = 0;

    for k = 1:256
        temp = array(k);
        if temp == 0
            r = r + 1;
        else
            while r > 15
                bufferIt(fid, AC_matrix(ACcode, hex2dec('F0') + 1, 1), AC_matrix(ACcode, hex2dec('F0') + 1, 2));
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
            bufferIt(fid, temp2, nbits);

            r = 0;
        end
    end

    if r > 0
        bufferIt(fid, AC_matrix(ACcode, 1, 1), AC_matrix(ACcode, 1, 2));
    end

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

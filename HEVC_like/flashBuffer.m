function flashBuffer(fid) 
    global bufferPutBits;
    global bufferPutBuffer;
    global output;
    PutBuffer = bufferPutBuffer;
    PutBits = bufferPutBits;
    while PutBits >= 8 
        c = bitand(bitshift(PutBuffer, -16), hex2dec('FF'));
        fwrite(fid, c);
        
        if c == hex2dec('FF')
            fwrite(fid, 0);
        end
        PutBuffer = bitshift(PutBuffer, 8);
        PutBits = PutBits - 8;
    end
    if PutBits > 0 
        c = bitand(bitshift(PutBuffer, -16), hex2dec('FF'));
        fwrite(fid, c);
    end
    fwrite(fid, output);
end
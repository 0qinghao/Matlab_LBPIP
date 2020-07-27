function writeEOI(fid)

    eoi(1) = hex2dec('FF');
    eoi(2) = hex2dec('D9');
    fwrite(fid, eoi);

end

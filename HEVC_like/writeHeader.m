
function writeHeader(fid, height, width)
    global quantLumMatrix;
    global quantChromMatrix;
    global zigZagOrder;
    global bits;
    global values;

    %SOI marker
    soi(1) = hex2dec('FF');
    soi(2) = hex2dec('D8');
    fwrite(fid, soi);

    %JFIF Header
    jfif(1) = hex2dec('FF');
    jfif(2) = hex2dec('E0'); %marker
    jfif(3) = hex2dec('00');
    jfif(4) = hex2dec('10'); %16
    jfif(5) = 'J';
    jfif(6) = 'F';
    jfif(7) = 'I';
    jfif(8) = 'F';
    jfif(9) = hex2dec('00');
    jfif(10) = hex2dec('01'); %vh
    jfif(11) = hex2dec('00'); %vl
    jfif(12) = hex2dec('00');
    jfif(13) = hex2dec('00');
    jfif(14) = hex2dec('01'); %xden
    jfif(15) = hex2dec('00');
    jfif(16) = hex2dec('01'); %yden
    jfif(17) = hex2dec('00');
    jfif(18) = hex2dec('00');
    fwrite(fid, jfif);
    
    %DQT Header
    dqt(1) = hex2dec('FF');
    dqt(2) = hex2dec('DB'); %marker
    dqt(3) = hex2dec('00');
    dqt(4) = hex2dec('84'); %132
    dqt(5) = hex2dec('00'); %y_marker
    offset = 5;
    for i=1:64
        offset = offset + 1;
        dqt(offset) = quantLumMatrix(zigZagOrder(i));
    end
    offset = offset + 1;
    dqt(offset) = hex2dec('01'); %cb_cr nraker
    for i=1:64
        offset = offset + 1;
        dqt(offset) = quantChromMatrix(zigZagOrder(i));
    end
    fwrite(fid, dqt);
    
    % Start of Frame Header
    SOF(1) = hex2dec('FF');
    SOF(2) = hex2dec('C0');
    SOF(3) = hex2dec('00');
    SOF(4) = 17;
    SOF(5) = 8;
    SOF(6) = bitand(bitshift(height, -8), hex2dec('FF'));
    SOF(7) = bitand(height, hex2dec('FF'));
    SOF(8) = bitand(bitshift(width, -8), hex2dec('FF'));
    SOF(9) = bitand(width, hex2dec('FF'));
    SOF(10) = 3;
    index = 11;
    CompID = [1 2 3];
    HsampFactor = [1 1 1];
    VsampFactor = [1 1 1];
    QtableNumber = [0 1 1];
    
    for i = 1:SOF(10)
        SOF(index) = CompID(i);
        index = index + 1;
        SOF(index) = bitshift(HsampFactor(i), 4) + VsampFactor(i);
        index = index + 1;
        SOF(index) = QtableNumber(i);
        index = index + 1;
    end
    fwrite(fid, SOF);
    
    % The DHT Header
    length = 2;
    index = 4;
    oldindex = 4;
    DHT4 = zeros(1, 4);
    DHT4(1) = hex2dec('FF');
    DHT4(2) = hex2dec('C4');
    for i=1:4
        bytes = 0;
        DHT1(index - oldindex + 1) = bits{i}(0+1);
        index = index + 1;
        for j = 2:17
            temp = bits{i}(j);
            DHT1(index - oldindex + 1) = temp;
            index = index + 1;
            bytes = bytes + temp;
        end
        intermediateindex = index;
        for j = 1:bytes
            DHT2(index - intermediateindex + 1) = values{i}(j);
            index = index + 1;
        end
        DHT3(1:oldindex) = DHT4(1:oldindex);
        DHT3(oldindex+1:oldindex+17) = DHT1(1:17);
        DHT3(oldindex+17+1:oldindex+17+bytes) = DHT2(1:bytes);
        DHT4 = DHT3;
        oldindex = index;
    end
    DHT4(3) = bitand(bitshift(index - 2, -8), hex2dec('FF'));
    DHT4(4) = bitand(index - 2, hex2dec('FF'));
    fwrite(fid, DHT4);
    
    % Start of Scan Header
    CompID = [1, 2, 3];
    DCtableNumber = [0, 1, 1];
    ACtableNumber = [0, 1, 1];
    SOS(1) = hex2dec('FF');
    SOS(2) = hex2dec('DA');
    SOS(3) = hex2dec('00');
    SOS(4) = 12;
    SOS(5) = 3;
    index = 6;
    for i = 1:SOS(5)
        SOS(index) = CompID(i);
        index = index + 1;
        SOS(index) = bitshift(DCtableNumber(i), 4) + ACtableNumber(i);
        index = index + 1;
    end
    SOS(index) = 0;
    index = index + 1;
    SOS(index) = 63;
    index = index + 1;
    SOS(index) = bitshift(0, 4) + 0;
    index = index + 1;
    fwrite(fid, SOS);
end
function PredValAng = xPredIntraAng(src, r, c, dirMode)
    iWidth = 16;
    iHeight = 16;
    pSrc = src(r - 1:r + iHeight - 1, c - 1:c + iWidth - 1);

    modeDC = dirMode == 1; %1=DC
    if (modeDC)
        dcval = predIntraGetPredValDC(pSrc);
        PredValAng = repmat(dcval, 16, 16);
        return
    end

    bIsModeVer = (dirMode >= 18);
    if (bIsModeVer)
        intraPredAngleMode = dirMode - 26;
    else
        intraPredAngleMode = -(dirMode - 10);
    end
    absAngMode = abs(intraPredAngleMode);
    if (intraPredAngleMode < 0)
        signAng = -1;
    else
        signAng = 1;
    end

    angTable = [0, 2, 5, 9, 13, 17, 21, 26, 32];
    invAngTable = [0, 4096, 1638, 910, 630, 482, 390, 315, 256];
    invAngle = invAngTable(absAngMode);
    absAng = angTable(absAngMode);
    intraPredAngle = signAng * absAng;

    if (intraPredAngle < 0)
        if (bIsModeVer)
            refMainOffsetPreScale = iHeight - 1;
        else
            refMainOffsetPreScale = iWidth - 1;
        end
        refMainOffset = iHeight - 1;

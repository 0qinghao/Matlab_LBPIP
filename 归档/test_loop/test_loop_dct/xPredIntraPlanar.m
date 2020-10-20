function PredValPlanar = xPredIntraPlanar(src, r, c)
    iWidth = 16;
    iHeight = 16;
    pSrc = src(r - 1:r + iHeight - 1, c - 1:c + iWidth - 1);

    topRow = pSrc(1, 2:2 + iWidth - 1);
    leftColumn = pSrc(2:2 + iHeight - 1, 1);
    bottomLeft = pSrc(iHeight + 1, 1);
    topRight = pSrc(1, iWidth + 1);

    PredValPlanar = round((repmat(topRow, iHeight, 1) + repmat(leftColumn, 1, iWidth) + topRight + bottomLeft) / 4);

end

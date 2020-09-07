function pDcVal = predIntraGetPredValDC(pSrc)
    % % iInd = 0;
    iSum = 0;
    % % pDcVal = 0;
    iWidth = 16;
    iHeight = 16;

    % pSrc = src(r - 1:r + iHeight - 1, c - 1:c + iWidth - 1);

    iSum = iSum + sum(pSrc(1, 2:2 + iWidth - 1));
    iSum = iSum + sum(pSrc(2:2 + iHeight - 1, 1));

    pDcVal = round(iSum / (iWidth + iHeight));
end

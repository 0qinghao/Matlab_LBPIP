function PredValAng = predIntraAng(src, r, c, uiDirMode)
    if (uiDirMode == 0)% 0=planar
        PredValAng = xPredIntraPlanar(src, r, c);
    else
        PredValAng = xPredIntraAng(src, r, c, uiDirMode);
    end
end

function [PX, PY] = get_px_py(Seq_r, i, j, k, PU)
    ind = PU - k - 1;
    ii = i + ind;
    jj = j + ind;
    if ((ii >= 1) && (jj >= 1))
        PY = Seq_r(ii, jj:j + PU - 1);
        PX = Seq_r(ii:i + PU - 1, jj);
    elseif ((ii >= 1) && (~(jj >= 1)))
        PY = [Seq_r(ii, jj + 1), Seq_r(ii, jj + 1:j + PU - 1)];
        PX = zeros(k + 1, 1) + PY(1);
    elseif (~(ii >= 1) && (jj >= 1))
        PX = [Seq_r(ii + 1, jj); Seq_r(ii + 1:i + PU - 1, jj)];
        PY = zeros(1, k + 1) + PX(1);
    else
        PX = zeros(k + 1, 1) + 128;
        PY = zeros(1, k + 1) + 128;
    end
end

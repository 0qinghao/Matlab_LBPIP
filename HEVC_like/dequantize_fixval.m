function out = dequantize_fixval(in, color_num, Q_fix)

    if (color_num == 1)
        outputData = round(in .* Q_fix);
    elseif (color_num == 2 || color_num == 3)
        outputData = round(in .* Q_fix);
    end

    out = outputData;
end

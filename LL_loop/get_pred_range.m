function pred_range = get_pred_range(PU, mask)
    all_range_1d = 1:PU^2;
    all_range = reshape(1:PU^2, PU, PU);
    lt_ind = all_range(1:PU / 2, 1:PU / 2);
    rt_ind = all_range(1:PU / 2, PU / 2 + 1:PU);
    lb_ind = all_range(PU / 2 + 1:PU, 1:PU / 2);
    rb_ind = all_range(PU / 2 + 1:PU, PU / 2 + 1:PU);
    l_ind = all_range(1:PU, 1:PU / 2);
    r_ind = all_range(1:PU, PU / 2 + 1:PU);
    switch mask
        case 1111
            pred_range = all_range_1d;
        case 0111
            pred_range = all_range_1d([lb_ind(:); r_ind(:)]);
        case 1011
            pred_range = all_range_1d([l_ind(:); rb_ind(:)]);
        case 1101
            pred_range = all_range_1d([lt_ind(:); r_ind(:)]);
        case 1110
            pred_range = all_range_1d([l_ind(:); rt_ind(:)]);
    end
    % pred_range = pred_range(:);
end

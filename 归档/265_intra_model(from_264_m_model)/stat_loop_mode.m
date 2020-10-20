[~, cnt] = size(mode_all_comb)
mode_sel_loop = [];
cc = 1;
for i = 1:cnt
    if numel(mode_all_comb{i}) > 1
        mode_sel_loop(cc, :) = diff(mode_all_comb{i});
        cc = cc + 1;
    end
end
tabulate(mode_sel_loop(:))

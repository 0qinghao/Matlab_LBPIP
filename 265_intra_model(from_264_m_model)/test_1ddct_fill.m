no_fill = prederr_cq_loop_all;
fill_0 = prederr_cq_loop_all;
fill_0(find(isnan(prederr_cq_loop_all))) = 0;
fill_end = prederr_cq_loop_all;
for l = 2:16
    ind = find(isnan(fill_end(l, :)), 1);
    fill_end(l, ind:end) = fill_end(l, ind - 1);
end

for Q = 1:32
    for l = 1:16
        dQ_fill0_t(l, :) = round(dct(fill_0(l, :)) / Q);
        re_fill0_t(l, :) = round(idct(dQ_fill0_t(l, :) * Q));
        dQ_fillend_t(l, :) = round(dct(fill_end(l, :)) / Q);
        re_fillend_t(l, :) = round(idct(dQ_fillend_t(l, :) * Q));
    end
    dQ_fill0{Q} = dQ_fill0_t;
    re_fill0{Q} = re_fill0_t;
    bits_fill0(Q) = huffman(dQ_fill0{Q});
    dQ_fillend{Q} = dQ_fillend_t;
    re_fillend{Q} = re_fillend_t;
    bits_fillend(Q) = huffman(dQ_fillend{Q});
end

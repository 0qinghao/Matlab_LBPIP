function output = rm_zero(in)
    index = find(in==0);
    if ~isempty(index)
        in(index) = 1;
    end
    output = in;
end
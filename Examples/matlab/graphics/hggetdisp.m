function hggetdisp(h)

%  Copyright 2012-2015 The MathWorks, Inc.

    p = properties(h);
    sp = sort(p).';
    v = get(h,sp);
    o = cell2struct(v,sp,2);
    disp(o)
end
function hgsetdisp(h)

%  Copyright 2012-2015 The MathWorks, Inc.

if ~isvalid(h)
    ME = MException('Graphics:InvalidDispObject', ...
        'Invalid or deleted object.');
    throw(ME);
else
    p = properties(h);
    sp = {};
    for i=1:length(p)
        pi = findprop(h,p{i});
        if strcmp( pi.SetAccess, 'public' )
            sp{end+1} = pi.Name;
        end
    end
    sp = sort(sp).';
    for i=1:length(sp)
        try
            v{i} = set(h,sp{i}).';
        catch
        end
    end
    o = cell2struct(v,sp,2);
    disp(o)
end
end

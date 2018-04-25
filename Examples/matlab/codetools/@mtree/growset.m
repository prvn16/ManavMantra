function o = growset( o, fh )
%GROWSET  obj = GROWSET( obj, fh )  Enlarge obj using function fh
%   GROWSET grows obj by adding nodes o where fh( o, obj ) is true
%   If continues this process until fh( o, obj ) is false for all
%   nodes o not in the expanded obj.

% Copyright 2006-2014 The MathWorks, Inc.

    work = true;
    oo = null( o );
    while work
        work = false;
        for i=find( ~o.IX )
            % i is not in o
            ooo = oo;
            ooo.IX(i) = true;
            if fh( o, ooo )
                o.IX(i) = true;
                work = true;
            end
        end
    end
    o.m = sum(o.IX);
end

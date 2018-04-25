function o = last( o )
%LAST  o = LAST( obj )   The last node in an Mtree List

% Copyright 2006-2014 The MathWorks, Inc.

    while true
        oo = X(o);
        o = (o - P(oo)) | oo;
        if isnull(oo)
            return;
        end
    end
end

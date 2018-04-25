function oo = trueparent(o)
%TRUEPARENT  o = TRUEPARENT(obj)  Parent node of a List

% Copyright 2006-2014 The MathWorks, Inc.

    II = o.T( o.IX, 13 );
    II(II==0) = [];
    oo = makeAttrib( o, II );
end

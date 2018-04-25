function a = kind( o )
%KIND  str = KIND( obj )   Return the Kind name for a node

% Copyright 2006-2014 The MathWorks, Inc.

    if count(o) ~= 1
        error(message('MATLAB:mtree:kind'));
    end
    a = o.KK{ o.T( o.IX, 1 ) };
end

function chk( o )
%CHK  CHK(obj)  Internal use only (for debugging).
% DEBUGGING: check an object

% Copyright 2006-2014 The MathWorks, Inc.

    if length( o.IX ) ~= o.n
        error(message('MATLAB:mtree:internal11'));
    end
    if o.n > size(o.T,1)
        error(message('MATLAB:mtree:internal12'));
    end
    if o.m < 0 || o.m > o.n
        error(message('MATLAB:mtree:internal13'));
    end
    if sum( o.IX ) ~= o.m
        error(message('MATLAB:mtree:internal14'));
    end
end

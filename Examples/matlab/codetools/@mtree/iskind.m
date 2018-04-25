function b = iskind( o, kind )
%ISKIND  b = ISKIND( obj, K )  true if node has kind K
%   K may be a string or a cell array of string
%   b will be a vector if the object has more than one node

% Copyright 2006-2017 The MathWorks, Inc.

    if isa( kind, 'cell' )
        b = false(1,o.m);
        for j=1:length(kind)
            try
                k = o.K.(kind{j});  % a desired kind
            catch x
                error(message('MATLAB:mtree:kind'));
            end
            b = b | (o.T(o.IX, 1)' == k);
        end
    else
        try
            k = o.K.(kind);
        catch x
            error(message('MATLAB:mtree:kind'));
        end
        b = o.T(o.IX, 1)' == k;
    end
end

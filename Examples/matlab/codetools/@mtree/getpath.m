function s = getpath( o, r )
%GETPATH  s = getpath( o, r )  returns the raw path from o to f

% Copyright 2006-2014 The MathWorks, Inc.

    if nargin<2
        r = root(o);
    end
    x = r;
    s = '.';
    while x ~= r
        if isnull(x)
            s = '';
            return;  % no path from r to o
        end
        y = mtpath( x, 'Parent' );
        if x == mtpath( y, 'L' )
            s = [ '.L' s ]; %#ok<AGROW>
        elseif x == mtpath( y, 'R' )
            s = [ '.R' s ]; %#ok<AGROW>
        elseif x == mtpath( y, 'N' )
            s = [ '.N' s ]; %#ok<AGROW>
        else
            error(message('MATLAB:mtree:impossiblePath'));
        end
        if y == r
            return;
        end
    end
end

function s = string( o )
%STRING str = STRING( o )  return a string for an Mtree node

% Copyright 2006-2014 The MathWorks, Inc.

    % o must be a single element set -- returns the string
    % an error if count(o)~=1 or the node does not have a string
    i = find( o.IX );
    if length(i)~=1
        error(message('MATLAB:mtree:string'));
    end
    i = o.T(i,8);
    if i==0
        error(message('MATLAB:mtree:nostring'));
    end
    s = o.C{i};
end

function mdbclearfunction(fullPath)
%MDBCLEARFUNCTION helper file for editor
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

% Copyright 2009 The MathWorks, Inc.

try
    dbclear('-completenames', fullPath);
catch exception %#ok<NASGU>
    %do nothing but don't pollute the lasterr space
end
end

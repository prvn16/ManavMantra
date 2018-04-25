function validateGeneratedPathname(pathName,propOrParamName)
% This function is undocumented and may change in a future release.

%  Copyright 2016 The MathWorks, Inc.

validateattributes(pathName,{'char','string'},{'scalartext'});
pathName = char(pathName);

try
    matlab.unittest.internal.validatePathname(pathName);
catch err
    error(message('MATLAB:unittest:FileIO:InvalidDueToInvalidPathname',propOrParamName,err.message));
end
end
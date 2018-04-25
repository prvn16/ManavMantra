function packagedName = makePackagedName(packageName, className)
    if isempty(packageName)
        packagedName = className;
    else
        packagedName = [packageName '.' className];
    end
end

%   Copyright 2007 The MathWorks, Inc.

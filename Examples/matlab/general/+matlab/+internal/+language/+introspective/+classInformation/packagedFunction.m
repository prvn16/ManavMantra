classdef packagedFunction < matlab.internal.language.introspective.classInformation.packagedItem
    methods
        function ci = packagedFunction(packageName, packagePath, itemName, itemExt)
            ci@matlab.internal.language.introspective.classInformation.packagedItem(packageName, packagePath, itemName, [itemName, itemExt]);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

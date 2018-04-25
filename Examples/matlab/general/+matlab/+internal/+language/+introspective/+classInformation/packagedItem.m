classdef packagedItem < matlab.internal.language.introspective.classInformation.base
    properties
        packagedName = '';
    end

    methods
        function ci = packagedItem(packageName, packagePath, itemName, itemFullName)
            definition = fullfile(packagePath, itemFullName);
            ci@matlab.internal.language.introspective.classInformation.base(definition, definition, definition);
            ci.packagedName = [packageName '.' itemName];
        end
        
        function topic = fullTopic(ci)
            topic = ci.packagedName;
        end
        
        function k = getKeyword(~)
            k = 'packagedItem';
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

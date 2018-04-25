classdef package < matlab.internal.language.introspective.classInformation.base
    properties (SetAccess=private, GetAccess=private)
        isExplicit = false;
        packageName = '';
    end
    
    methods
        function ci = package(packagePath, isExplicit)
            ci@matlab.internal.language.introspective.classInformation.base(matlab.internal.language.introspective.getPackageName(packagePath), packagePath, packagePath);
            ci.isExplicit = isExplicit;
            ci.packageName = ci.definition;
            ci.isPackage = true;
        end

        function topic = fullTopic(ci)
            % since the definition has been modified by overqualifyTopic,
            % this needs to be overloaded to keep things nice.          
            topic = ci.packageName;
        end
    end

    methods (Access=protected)
        function overqualifyTopic(ci, topic)
            % if a package name has been overqualified to distinguish it from
            % another directory, add it back here
            overqualifiedPath = matlab.internal.language.introspective.splitOverqualification(ci.minimalPath, topic, ci.whichTopic);
            if ci.isExplicit
                ci.definition = [overqualifiedPath, ci.minimalPath];
            else
                ci.definition = [overqualifiedPath, regexprep(ci.minimalPath, '[@+]', '')];
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

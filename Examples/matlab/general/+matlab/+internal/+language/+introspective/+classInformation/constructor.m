classdef constructor < matlab.internal.language.introspective.classInformation.classItem
    properties (SetAccess=protected, GetAccess=protected)
        metaClass = [];
        packagedName = '';
        classError = false;
        classLoaded = false;
    end

    methods
        function ci = constructor(packageName, className, definition, whichTopic, justChecking)
            ci@matlab.internal.language.introspective.classInformation.classItem(packageName, className, definition, definition, whichTopic);
            if ~justChecking
                ci.loadClass;
                if ci.classError
                    ci.isAccessible = true;
                elseif isempty(ci.metaClass)
                    ci.isAccessible = true;
                else
                    ci.isAccessible = ~ci.metaClass.Hidden;
                end
            end
        end
        
        function b = isConstructor(ci)
            b = ~ci.isClass;
        end
        
        function b = isMCOSClassOrConstructor(ci)
            ci.loadClass;
            b = ci.classError || ~isempty(ci.metaClass);
        end
        
        function topic = fullTopic(ci)
            topic = ci.fullClassName;
            if ci.isConstructor
                topic = [topic '/' ci.className];
            end                
        end
        
        function k = getKeyword(~)
            k = 'constructor';
        end
    end

    methods (Access=protected)
        function loadClass(ci)
            if ~ci.classLoaded
                ci.classLoaded = true;
                try
                    ci.packagedName = matlab.internal.language.introspective.makePackagedName(ci.packageName, ci.className);
                    ci.metaClass = meta.class.fromName(ci.packagedName);
                catch e %#ok<NASGU>
                    ci.classError = true;
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

classdef packagedUnknown < matlab.internal.language.introspective.classInformation.packagedItem
    properties
        helpFunction = '';
    end
    
    methods
        function ci = packagedUnknown(packageName, packagePath, itemName, itemFullName, helpFunction)
            ci@matlab.internal.language.introspective.classInformation.packagedItem(packageName, packagePath, itemName, itemFullName);
            ci.helpFunction = helpFunction;
        end
    end
    
    methods (Access=protected)
        function [helpText, needsHotlinking, suppressedImplicit] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            helpText = matlab.internal.language.introspective.callHelpFunction(ci.helpFunction, ci.whichTopic);
            needsHotlinking = true;
            suppressedImplicit = false;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

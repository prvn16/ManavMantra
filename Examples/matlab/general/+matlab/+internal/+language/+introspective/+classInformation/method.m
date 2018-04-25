classdef method < matlab.internal.language.introspective.classInformation.classElement   
    properties (SetAccess=private, GetAccess=private)
        classWrapper;
    end
    
    properties (SetAccess=public, GetAccess=private)
        inheritHelp = true;
    end
    
    methods
        function ci = method(classWrapper, packageName, className, methodName, definition, minimalPath, whichTopic)
            ci@matlab.internal.language.introspective.classInformation.classElement(packageName, className, methodName, definition, minimalPath, whichTopic);
            ci.classWrapper = classWrapper;
            ci.isMethod = true;
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            helpText = '';
            needsHotlinking = false;
            if ci.inheritHelp
                [helpText, needsHotlinking, superClassInfo, ci.superWrapper] = ci.classWrapper.getShadowedHelp(ci.element, hotLinkCommand);
                if ~isempty(superClassInfo)
                    % definition needs to refer to the implementation
                    ci.definition = superClassInfo.definition;
                end
            end
            if isempty(helpText)
                helpText = ci.classWrapper.getElementDescription(ci.element);
            end
        end
        
        function k = getKeyword(~)
            k = 'methods';
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

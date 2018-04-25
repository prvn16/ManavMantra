classdef simpleMCOSElement < matlab.internal.language.introspective.classInformation.simpleElement
    properties (SetAccess=private, GetAccess=private)
        elementMeta;
    end    

    methods
        function ci = simpleMCOSElement(className, elementMeta, classPath, elementKeyword, packageName)
            ci = ci@matlab.internal.language.introspective.classInformation.simpleElement(className, elementMeta.Name, classPath, elementKeyword, packageName);
            ci.elementMeta = elementMeta;
        end
        
        function b = isAccessibleElement(ci, classElement)
            b = matlab.internal.language.introspective.isAccessible(classElement, ci.elementKeyword);
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(ci, ~)
            helpText = ci.elementMeta.Description;
            needsHotlinking = true;
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking, suppressedImplicit] = helpfunc(ci, hotLinkCommand) %#ok<INUSD>
            helpText = getElementHelp(ci, ci.whichTopic);
            needsHotlinking = true;
            suppressedImplicit = false;
        end 

        function allElementHelps = getAllElementHelps(ci, classFile)
            elementSections = regexp(classFile, ['^\s*', ci.elementKeyword, '\>.*(?<inside>.*\n)*?^\s*end\>'], 'names', 'dotexceptnewline', 'lineanchors');
            % cast the input to regexp to char so empty will do the right thing
            allElementHelps = regexp(char([elementSections.inside]), '^(?<preHelp>[ \t]*+%.*+\n)*[ \t]*+(?<element>\w++)(''[^\n'']*+''|[^\n%])*+(?<postHelp>%.*+\n)?', 'names', 'dotexceptnewline', 'lineanchors');
        end
    end
    
    methods (Static, Access=protected)
        function [helpText, prependName] = extractHelpText(elementHelp)
            prependName = false;
            if ~isempty(elementHelp.preHelp)
                helpText = elementHelp.preHelp;
            else
                prependName = true;
                helpText = elementHelp.postHelp;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

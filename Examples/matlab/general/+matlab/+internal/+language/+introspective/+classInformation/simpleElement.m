classdef simpleElement < matlab.internal.language.introspective.classInformation.classElement
    properties (SetAccess=private, GetAccess=protected)
        foundElement = false;
        elementKeyword;
    end

    methods
        function ci = simpleElement(className, elementName, classPath, elementKeyword, packageName)
            definition = fullfile(classPath, [className filemarker elementName]);
            whichTopic = which(fullfile(classPath, className));
            ci@matlab.internal.language.introspective.classInformation.classElement(packageName, className, elementName, definition, definition, whichTopic)
            ci.elementKeyword = elementKeyword;
            ci.isSimpleElement = true;
        end

        function topic = fullTopic(ci)
            topic = [matlab.internal.language.introspective.makePackagedName(ci.packageName, ci.className), ci.separator, ci.element];
        end
        
        function k = getKeyword(ci)
            k = ci.elementKeyword;
        end
    end
    
    methods (Access=protected)
        function helpText = getElementHelp(ci, helpFile)
            helpText = matlab.internal.language.introspective.callHelpFunction(@ci.getHelpTextFromFile, helpFile);
        end
    end
    
    methods (Access=private)
        function helpText = getHelpTextFromFile(ci, fullPath)
            helpText = '';
            if ~ci.foundElement
                classFile = matlab.internal.getCode(fullPath);
                allElementHelps = ci.getAllElementHelps(classFile);
                allElementHelps(~strcmp(ci.element, {allElementHelps.element})) = [];
                for elementHelp = allElementHelps
                    ci.foundElement = true;
                    [helpText, prependName] = ci.extractHelpText(elementHelp);
                    if ~isempty(helpText)
                        helpText = regexprep(helpText, '^\s*%', ' ', 'lineanchors');
                        helpText = regexprep(helpText, '\r', '');
                        if prependName
                            helpText = [' ' ci.element ' -' helpText]; %#ok<AGROW>
                        end
                        return;
                    end
                end
            end
        end
    end
    
    methods (Abstract, Access=protected)
        allElementHelps = getAllElementHelps(ci, classFile)        
    end

    methods (Static, Abstract, Access=protected)
        [helpText, prependName] = extractHelpText(elementHelp)
    end
end

%   Copyright 2012 The MathWorks, Inc.

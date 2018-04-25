classdef base < handle
    properties (SetAccess=protected, GetAccess=public)
        minimalPath = '';
        definition = '';
        
        isPackage = false;
        isMethod = false;
        isSimpleElement = false;
    end
    
    properties
        isAccessible = true;
    end

    properties (SetAccess=protected, GetAccess=protected)
        whichTopic = '';
    end

    properties (SetAccess=private, GetAccess=private)
        foundAlternateHelpFunction = false;
        alternateHelpFunction = '';
    end

    properties (SetAccess=public, GetAccess=private)
        unaryName = '';
        isMinimal = false;
    end

    methods
        function ci = base(definition, minimalPath, whichTopic)
            ci.definition = definition;
            ci.minimalPath = minimalPath;
            ci.whichTopic = whichTopic;
        end
        
        function whichTopic = minimizePath(ci)
            whichTopic = ci.whichTopic;
            if ~isempty(ci.minimalPath)
                if ci.isMinimal
                    pathParts = regexp(ci.minimalPath, '^(?<qualifyingPath>[^@+]*)(?(qualifyingPath)[\\/])(?<pathItem>.*)', 'names', 'once');
                    ci.minimalPath = pathParts.pathItem;                    
                else
                    ci.minimalPath = matlab.internal.language.introspective.minimizePath(ci.minimalPath, ci.isPackage || ci.isConstructor);
                end
            end
        end
        
        function insertClassName(ci) %#ok<MANU>
        end

        function [helpText, needsHotlinking, suppressedImplicit] = getHelp(ci, hotLinkCommand, topic, wantHyperlinks)
            if nargin < 4
                wantHyperlinks = 0;
                if nargin < 3
                    topic = '';
                    if nargin < 2
                        hotLinkCommand = '';
                    end
                end
            end
            ci.overqualifyTopic(topic);
            [helpText, needsHotlinking, suppressedImplicit] = ci.innerGetHelp(hotLinkCommand);
            if ~isempty(helpText)
                helpText = ci.postprocessHelp(helpText, wantHyperlinks);
            end
        end

        function [helpText, needsHotlinking, suppressedImplicit] = innerGetHelp(ci, hotLinkCommand)
            [helpText, needsHotlinking, suppressedImplicit] = ci.helpfunc(hotLinkCommand);
            if isempty(helpText)
                [helpText, needsHotlinking] = ci.getSecondaryHelp(hotLinkCommand);
            end
        end
        
        function b = hasHelp(ci)
            b = checkHelp(ci);
        end
        
        function b = checkHelp(ci)
            if ci.hasAlternateHelpFunction
                b = ~isempty(matlab.internal.language.introspective.callHelpFunction(ci.alternateHelpFunction, ci.definition));
            else
                b = builtin('helpfunc', ci.definition, '-justChecking');
            end
        end
        
        function docTopic = getDocTopic(ci, ~)
            docTopic = innerGetDocTopic(ci, ci.fullTopic, false);
        end
        
        function set.unaryName(ci, name)
            if ~isempty(regexp(name, '^\w*$', 'once'))
                ci.unaryName = matlab.internal.language.introspective.extractCaseCorrectedName(ci.definition, name); %#ok<MCSUP>
            end
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(~, ~) 
            helpText = '';
            needsHotlinking = false;
        end
            
        function topic = fullTopic(ci)
            topic = ci.definition;
        end

        function b = isClass(~)
            b = false;
        end

        function b = isConstructor(~)
            b = false;
        end

        function b = isMCOSClassOrConstructor(~)
            b = false;
        end
        
        function b = isMCOSClass(ci)
            b = ci.isClass() && ci.isMCOSClassOrConstructor();
        end
        
        function k = getKeyword(~)
            k = '';
        end
    end

    methods (Access=protected)
        function [helpText, needsHotlinking, suppressedImplicit] = helpfunc(ci, hotLinkCommand)
            if ci.hasAlternateHelpFunction
                helpText = matlab.internal.language.introspective.callHelpFunction(ci.alternateHelpFunction, ci.definition);
                needsHotlinking = true;
                suppressedImplicit = false;
            else
                [helpText, needsHotlinking, suppressedImplicit] = builtin('helpfunc', ci.definition, '-hotlink', hotLinkCommand, '-actual', ci.unaryName);
            end
        end

        function helpText = postprocessHelp(~, helpText, ~) 
        end

        function overqualifyTopic(~, ~) 
        end
        
        function docTopic = innerGetDocTopic(ci, topic, isClassElement)
            topic = strrep(topic, '/', '.');
            docTopic = matlab.internal.language.introspective.getDocTopic(ci.definition, topic, isClassElement);
        end
        
        function b = hasAlternateHelpFunction(ci)
            if ~ci.foundAlternateHelpFunction
                ci.foundAlternateHelpFunction = true;
                [ci.alternateHelpFunction, ~, targetExtension] = matlab.internal.language.introspective.getAlternateHelpFunction(ci.whichTopic);
                b = ~isempty(ci.alternateHelpFunction);
                if b
                    [definitionPath, definitionName, definitionExt] = fileparts(ci.definition);
                    if isempty(definitionExt)
                        [split, match] = regexp(definitionName, filemarker, 'split', 'match', 'once');
                        ci.definition = [definitionPath, filesep, split{1}, targetExtension, match, split{2:end}];
                    end
                end
            else
                b = ~isempty(ci.alternateHelpFunction);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

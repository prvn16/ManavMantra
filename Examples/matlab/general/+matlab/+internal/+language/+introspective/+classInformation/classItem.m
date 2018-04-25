classdef classItem < matlab.internal.language.introspective.classInformation.base
    properties
        packageName = '';
        className = '';
        superWrapper = [];
        fullSuperClassName = '';
        superClassName = '';
    end

    methods
        function ci = classItem(packageName, className, definition, minimalPath, whichTopic)
            ci@matlab.internal.language.introspective.classInformation.base(definition, minimalPath, whichTopic);
            ci.packageName = packageName;
            ci.className = className;
        end
    end
    
    methods (Access=protected)
        function topic = fullClassName(ci)
            topic = matlab.internal.language.introspective.makePackagedName(ci.packageName, ci.className);
        end

        function helpText = postprocessHelp(ci, helpText, wantHyperlinks)
            ci.prepareSuperClassName;
            if ~isempty(ci.fullSuperClassName)
                helpParts = matlab.internal.language.introspective.helpParts(helpText);
                seeAlsoPart = helpParts.getPart('seeAlso');
                if ~isempty(seeAlsoPart)
                    fullSubClassName =  ci.fullClassName;
                    newMethodName = @(oldMethodName) ci.conditionalMethodName(oldMethodName, ci.superClassName);  %#ok<NASGU>
                    modifiedSeeAlso = regexprep(seeAlsoPart.getText, ['(?<=[\s,]|^)' ci.fullSuperClassName '\>(.\w*\>)?'], [fullSubClassName '${newMethodName($1)}'], 'preservecase');

                    seeAlsoPart.replaceText(modifiedSeeAlso);
                    helpText = helpParts.getFullHelpText;
                end
                
                if ci.superWrapper.hasClassHelp
                    helpText = getString(message('MATLAB:introspective:displayHelp:HelpInheritedFromSuperclass', helpText, ci.fullTopic, hyperName(ci.fullSuperClassName, wantHyperlinks)));
                end
            end
        end
        
        function prepareSuperClassName(ci)
            if ~isempty(ci.superWrapper)
                % now note that we've updated the help for the subclass
                ci.fullSuperClassName = matlab.internal.language.introspective.getPackageName(ci.definition);
                if ~any(ci.definition=='@')
                    ci.superClassName = regexp(ci.definition, ['\<(\w+)(?:\.\w+)?' filemarker], 'tokens', 'once');
                    ci.fullSuperClassName = matlab.internal.language.introspective.makePackagedName(ci.fullSuperClassName, ci.superClassName{1});
                else
                    ci.superClassName = regexp(ci.fullSuperClassName, '\w*$', 'match', 'once');
                end
            end
        end
    end

    methods (Access=private)
        function newMethodName = conditionalMethodName(ci, oldMethodName, superClassName)
            if strcmpi(oldMethodName(2:end), superClassName)
                % this "method" is the constructor for the superClass, replace with
                % the className so that it is still the constructor
                newMethodName = [oldMethodName(1) ci.className];
            else
                newMethodName = oldMethodName;
            end
        end
    end
end

function className = hyperName(className, wantHyperlinks)
    if wantHyperlinks
        % dual is OK here, since classNames are always safe
        className = ['<a href="matlab:help ' className '">' className '</a>'];
    else
        className = upper(className);
    end
end

%   Copyright 2007 The MathWorks, Inc.

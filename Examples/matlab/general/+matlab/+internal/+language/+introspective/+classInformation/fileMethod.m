classdef fileMethod < matlab.internal.language.introspective.classInformation.method
    methods
        function ci = fileMethod(classWrapper, className, basePath, derivedPath, methodName, fileType, packageName)
            fileName = [methodName fileType];
            definition = fullfile(basePath, fileName);
            whichTopic = fullfile(derivedPath, fileName);
            ci@matlab.internal.language.introspective.classInformation.method(classWrapper, packageName, className, methodName, definition, whichTopic, whichTopic);
        end

        function insertClassName(ci)
            ci.minimalPath = regexprep(ci.minimalPath, '(.*[\\/])(.*)', ['$1' ci.className filemarker '$2']);
        end
        
        function setAccessible(ci)
            try
                packagedName = matlab.internal.language.introspective.makePackagedName(ci.packageName, ci.className);
                metaClass = meta.class.fromName(packagedName);
                if isempty(metaClass)
                    ci.isAccessible = true;
                else
                    classMethod = matlab.internal.language.introspective.getMethod(metaClass, ci.element);
                    ci.setStatic(classMethod.Static);
                    if metaClass.Hidden
                        ci.isAccessible = false;
                    else
                        ci.isAccessible = matlab.internal.language.introspective.isAccessible(classMethod, 'methods');
                    end
                end
            catch e %#ok<NASGU>
                % probably an error parsing the class file
                ci.isAccessible = false;
            end
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            % Did not find help for a file function, see if there is help for a local function.
            % This is for an anomalous case, in which a method is defined as both a file in an @-dir
            % and as a local function in a classdef, in which the local function will trump the file.
            ci.definition = regexprep(ci.definition, '@(?<className>\w++)[\\/](?<methodName>\w*)(?<m>\.m)?(?<ext>(?(m)|\.\w+))?$', ['@$<className>/$<className>$<ext>' filemarker '$<methodName>']);
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
            if isempty(helpText)
                [helpText, needsHotlinking] = ci.getSecondaryHelp@matlab.internal.language.introspective.classInformation.method(hotLinkCommand);
            end            
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

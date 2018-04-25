classdef fileConstructor < matlab.internal.language.introspective.classInformation.constructor
    properties (SetAccess=protected, GetAccess=protected)
        noAtDir = true;
        classPath = '';
        classWrapper = [];
        isCaseSensitive = false;
    end
    
    methods
        function ci = fileConstructor(packageName, className, classPath, fullPath, noAtDir, justChecking, isCaseSensitive)
            ci@matlab.internal.language.introspective.classInformation.constructor(packageName, className, fullPath, fullPath, justChecking);
            ci.classPath = classPath;
            ci.noAtDir = noAtDir;
            
            if nargin > 6
               ci.isCaseSensitive = isCaseSensitive; 
            end
        end
        
        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            ci.prepareForSecondaryHelp;
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
        end
        
        function b = hasHelp(ci)
            b = ci.checkHelp;
            if ~b
                ci.prepareForSecondaryHelp;
                b = ci.checkHelp;
            end
        end
        
        function constructorInfo = getConstructorInfo(ci, useClassHelp)
            constructorInfo = [];
            if useClassHelp || ci.checkHelp
                % only concerned with constructor info if there is both class and constructor help
                constructorInfo = matlab.internal.language.introspective.classInformation.localConstructor(ci.packageName, ci.className, ci.classPath, false);
                if ~useClassHelp && ~constructorInfo.hasHelp;
                    constructorInfo = [];                    
                end
            end
        end
        
        function methodInfo = getMethodInfo(ci, classMethod, inheritHelp)
            ci.createWrapper;
            methodInfo = ci.classWrapper.getMethod(classMethod);
            if ~isempty(methodInfo)
                methodInfo.inheritHelp = inheritHelp;
            end
        end
        
        function elementInfo = getSimpleElementInfo(ci, classElement, elementKeyword)
            ci.createWrapper;
            elementInfo = ci.classWrapper.getSimpleElement(classElement, elementKeyword, false);
        end
    end
    
    methods (Access=private)
        function prepareForSecondaryHelp(ci)
            % did not find help for the constructor, see if there is help for the localFunction constructor
            [filePath, ~, fileExt] = fileparts(ci.whichTopic);
            if strcmp(fileExt, '.m')
                ci.definition = [filePath filesep ci.className filemarker ci.className];
            else
                ci.definition = [ci.whichTopic filemarker ci.className];
            end
        end

        function createWrapper(ci)
            if isempty(ci.classWrapper)
                if ci.noAtDir
                    packagePath = ci.classPath;
                else
                    packagePath = fileparts(ci.classPath);
                end
                ci.classWrapper = matlab.internal.language.introspective.classWrapper.rawMCOS(ci.className, '', packagePath, ci.packageName, ci.noAtDir, false, ci.isCaseSensitive);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

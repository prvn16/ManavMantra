classdef MCOS < matlab.internal.language.introspective.classWrapper.base
    properties (SetAccess=protected, GetAccess=protected)
        metaClass = [];
        packagedName = '';
        classDir = '';
        classHasNoAtDir = false;
        fileType = '';
    end
    
    methods
        function [helpText, needsHotlinking, shadowedClassInfo, shadowedWrapper] = getShadowedHelp(cw, elementName, hotLinkCommand)
            helpText = '';
            needsHotlinking = false;
            shadowedClassInfo = [];
            shadowedWrapper = [];
            cw.loadClass;
            if ~isempty(cw.metaClass)
                supers = cw.metaClass.SuperClasses;
                for i = 1:length(supers)
                    super = supers{i};
                    superMethod = matlab.internal.language.introspective.getMethod(super, elementName);
                    if ~isempty(superMethod)
                        definingClass = superMethod.DefiningClass;
                        [shadowedClassInfo, definingClassWrapper] = cw.getSuperClassInfo(definingClass, superMethod.Abstract, superMethod.Static, elementName);
                        % hasHelp is recursive, so superclass shadowed classes will be found
                        if ~isempty(shadowedClassInfo)
                            [helpText, needsHotlinking] = shadowedClassInfo.innerGetHelp(hotLinkCommand);
                            if ~isempty(helpText)
                                shadowedWrapper = definingClassWrapper;
                                return;
                            end
                        end
                    end
                end
            end
        end
        
        function helpText = getElementDescription(cw, elementName)
            helpText = '';
            cw.loadClass;
            if ~isempty(cw.metaClass)
                methodMeta = matlab.internal.language.introspective.getMethod(cw.metaClass, elementName);
                helpText = methodMeta.Description;
            end
        end
    end
    
    methods (Access=protected)
        function cw = MCOS(packagedName, className, classDir)
            cw.packagedName = packagedName;
            cw.className = className;
            cw.classDir = classDir;
            if ~isempty(regexp(cw.classDir, ['@' cw.className '$'], 'once'))
                cw.classPaths = {cw.classDir};
            end
        end
        
        function loadClass(cw)
            if isempty(cw.metaClass)
                try %#ok<TRYNC> probably an error parsing the class file
                    cw.metaClass = meta.class.fromName(cw.packagedName);
                end
            end
        end
        
        function [classInfo, definingClassWrapper] = getSuperClassInfo(cw, definingClass, isAbstractMethod, isStaticMethod, elementName)
            definingClassWrapper = matlab.internal.language.introspective.classWrapper.superMCOS(definingClass, cw.subClassPath, cw.subClassName, cw.subClassPackageName, cw.isCaseSensitive, isAbstractMethod, isStaticMethod);
            classInfo = definingClassWrapper.getElement(elementName, false);
            if ~isempty(classInfo)
                classInfo.className = cw.className;
                if cw.classHasNoAtDir
                    classInfo.insertClassName;
                end
                definingClassWrapper.classHasNoAtDir = cw.classHasNoAtDir;
                classInfo.superWrapper = definingClassWrapper;
            end
        end
        
        function classInfo = innerGetLocalMethod(cw, methodName, isAbstract, isStatic)
            classInfo = [];
            if ~isempty(cw.classDir)
                classMFile = which(fullfile(cw.classDir, cw.className));
                [~, ~, ext] = fileparts(classMFile);
                if ~strcmp(ext, '.p') && ~isAbstract && ~any(strcmp(which('-subfun',classMFile), [cw.className '.' methodName]))
                    return;
                end
                if isAbstract
                    classInfo = matlab.internal.language.introspective.classInformation.abstractMethod(cw, cw.className, cw.classDir, classMFile, cw.subClassPath, cw.subClassName, methodName, cw.subClassPackageName);
                else
                    classInfo = matlab.internal.language.introspective.classInformation.localMethod(cw, cw.className, cw.classDir, classMFile, cw.subClassPath, cw.subClassName, methodName, cw.subClassPackageName);
                end
                classInfo.setStatic(isStatic);
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

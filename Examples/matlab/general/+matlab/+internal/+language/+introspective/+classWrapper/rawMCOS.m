classdef rawMCOS < matlab.internal.language.introspective.classWrapper.MCOS & matlab.internal.language.introspective.classWrapper.raw
    properties (SetAccess=private, GetAccess=private)
        packageName = '';
    end

    methods
        function cw = rawMCOS(className, fileType, packagePath, packageName, classHasNoAtDir, isUnspecifiedConstructor, isCaseSensitive)
            
            packagedName = matlab.internal.language.introspective.makePackagedName(packageName, className);
            
            if classHasNoAtDir
                classDir = packagePath;
            else
                classDir = fullfile(packagePath, ['@', className]);
            end
            
            cw = cw@matlab.internal.language.introspective.classWrapper.MCOS(packagedName, className, classDir);
            
            cw.classHasNoAtDir          = classHasNoAtDir;
            cw.isUnspecifiedConstructor = isUnspecifiedConstructor;
            cw.packageName              = packageName;
            cw.fileType                 = fileType;
            cw.subClassPath             = classDir;
            cw.subClassPackageName      = cw.packageName;
            cw.subClassName             = cw.className;
            cw.isCaseSensitive          = isCaseSensitive;
        end

        function classInfo = getConstructor(cw, justChecking)
            if cw.isUnspecifiedConstructor
                classInfo = matlab.internal.language.introspective.classInformation.fullConstructor(cw, cw.packageName, cw.className, cw.subClassPath, cw.classHasNoAtDir, true, justChecking);
            else
                classInfo = matlab.internal.language.introspective.classInformation.localConstructor(cw.packageName, cw.className, cw.subClassPath, justChecking);
            end
        end

        function classInfo = getElement(cw, elementName, justChecking)
            if cw.classHasNoAtDir
                classInfo = cw.getLocalElement(elementName, justChecking);
            else
                classInfo = cw.getElement@matlab.internal.language.introspective.classWrapper.MCOS(elementName, justChecking);
            end
            if ~isempty(classInfo)
                classInfo.setAccessible;
            end
        end
        
        function classInfo = getMethod(cw, classMethod)
            cw.loadClass;
            elementName = classMethod.Name;

            classInfo = cw.getFileMethod(elementName);
            if isempty(classInfo)
                classInfo = cw.innerGetMethod(classMethod);
            else
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function classInfo = getSimpleElement(cw, classElement, elementKeyword, justChecking)
            cw.loadClass;

            if strcmp(elementKeyword, 'enumeration')
                definingClass = cw.metaClass;
            else
                definingClass = classElement.DefiningClass;
            end
            if definingClass == cw.metaClass || justChecking
                if ~justChecking && isempty(classElement.Description)
                    if isempty(which(fullfile(cw.classDir, cw.className)))
                        classInfo = [];
                        return;
                    end
                end
                classInfo = matlab.internal.language.introspective.classInformation.simpleMCOSElement(cw.className, classElement, cw.subClassPath, elementKeyword, cw.subClassPackageName);
            else
                definingClassWrapper = matlab.internal.language.introspective.classWrapper.superMCOS(definingClass, cw.subClassPath, cw.subClassName, cw.subClassPackageName, cw.isCaseSensitive);
                classInfo = definingClassWrapper.getSimpleElement(classElement, elementKeyword);
                classInfo.className = cw.className;
                classInfo.superWrapper = definingClassWrapper;
            end
            classInfo.isAccessible = ~cw.metaClass.Hidden && classInfo.isAccessibleElement(classElement);
            if strcmp(elementKeyword, 'properties')
                classInfo.setStatic(classElement.Constant);
            end
        end
    end

    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, justChecking)
            classInfo = [];
            cw.loadClass;
            if ~isempty(cw.metaClass)
                classMethod = matlab.internal.language.introspective.getMethod(cw.metaClass, elementName, cw.isCaseSensitive);

                if ~isempty(classMethod)
                    classInfo = cw.innerGetMethod(classMethod);
                else
                    [classElement, elementKeyword] = matlab.internal.language.introspective.getSimpleElement(cw.metaClass, elementName, cw.isCaseSensitive);

                    if ~isempty(classElement)
                        classInfo = cw.getSimpleElement(classElement, elementKeyword, justChecking);
                    end
                end
            end
        end
    end

    methods (Access=private)
        function classInfo = innerGetMethod(cw, classMethod)
            elementName = classMethod.Name;
            definingClass = classMethod.DefiningClass;
            if definingClass == cw.metaClass
                classInfo = innerGetLocalMethod(cw, elementName, classMethod.Abstract, classMethod.Static);
            else
                classInfo = cw.getSuperClassInfo(definingClass, classMethod.Abstract, classMethod.Static, elementName);
            end
            if ~isempty(classInfo)
                cw.setAccessibleMethod(classInfo, classMethod);
            end
        end

        function setAccessibleMethod(cw, classInfo, classMethod)
            classInfo.isAccessible = ~cw.metaClass.Hidden && matlab.internal.language.introspective.isAccessible(classMethod, 'methods');
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

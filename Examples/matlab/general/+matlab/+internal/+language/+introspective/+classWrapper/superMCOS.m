classdef superMCOS < matlab.internal.language.introspective.classWrapper.MCOS & matlab.internal.language.introspective.classWrapper.super
    properties (SetAccess=private, GetAccess=private)
        isAbstractMethod = false;
        isStaticMethod = false;
    end
    
    methods
        function cw = superMCOS(metaClass, subClassPath, subClassName, subClassPackageName, isCaseSensitive, isAbstractMethod, isStaticMethod)
            
            packagedName = metaClass.Name;
            className    = regexp(packagedName, '\w*$', 'match', 'once');
            classDir     = which(packagedName);
            classDir     = fileparts(classDir);
            
            if isempty(classDir)
                classResolver = matlab.internal.language.introspective.NameResolver(packagedName, [], true);
                classResolver.executeResolve(isCaseSensitive);
                classDir = classResolver.nameLocation;
                
                if isempty(classDir)
                    classDir = '';
                else
                    classDir = fileparts(classDir);
                end
            end
            
            cw = cw@matlab.internal.language.introspective.classWrapper.MCOS(packagedName, className, classDir);
            cw.metaClass = metaClass;
            
            if isempty(cw.classPaths)
                % classdef is not a MATLAB file
                packageList = regexp(cw.packagedName, '\w+(?=\.)', 'match');
                if isempty(packageList)
                    allClassDirs = matlab.internal.language.introspective.hashedDirInfo(['@' cw.className]);
                    cw.classPaths = {allClassDirs.path};
                else
                    topPackageDirs = matlab.internal.language.introspective.hashedDirInfo(['+' packageList{1}]);
                    packagePaths = {topPackageDirs.path};
                    if ~isscalar(packageList)
                        subpackages = sprintf('/+%s', packageList{2:end});
                        packagePaths = strcat(packagePaths, subpackages);
                    end
                    cw.classPaths = strcat(packagePaths, ['/@' cw.className]);
                end
            end
            
            cw.subClassPath          = subClassPath;
            cw.subClassName          = subClassName;
            cw.subClassPackageName   = subClassPackageName;
            
            if nargin > 4
                cw.isCaseSensitive = isCaseSensitive;
                if nargin > 5
                    cw.isAbstractMethod = isAbstractMethod;
                    if nargin > 6
                        cw.isStaticMethod = isStaticMethod;
                    end
                end
            end
        end

        function classInfo = getSimpleElement(cw, classElement, elementKeyword)
            classdefInfo = cw.getSimpleElementHelpFile;
            classInfo = matlab.internal.language.introspective.classInformation.simpleMCOSElement(cw.className, classElement, fileparts(classdefInfo.definition), elementKeyword, cw.subClassPackageName);
        end

        function b = hasClassHelp(cw)
            if cw.metaClass.Hidden
                b = false;
            elseif strcmp(cw.className, 'handle')
                b = true;
            else
                classInfo = cw.getClassHelpFile;
                b = classInfo.hasHelp;
            end
        end

        function classInfo = getSimpleElementHelpFile(cw)
            classInfo = cw.getClassHelpFile;
        end
    end
    
    methods (Access=protected)
        function classInfo = getLocalElement(cw, elementName, ~)
            classInfo = cw.innerGetLocalMethod(elementName, cw.isAbstractMethod, cw.isStaticMethod);
        end

        function b = isConstructor(~, ~) 
            b = false;
        end

        function classInfo = getClassHelpFile(cw)
            classInfo = matlab.internal.language.introspective.classInformation.simpleMCOSConstructor(cw.className, which(fullfile(cw.classDir, cw.className)), false);
        end
    end
end

%   Copyright 2007-2015 The MathWorks, Inc.

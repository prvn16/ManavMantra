function MCOSClassInformation(obj, topic, MCOSParts)

    if isempty(MCOSParts.packages)
        resolveWithoutMCOSPackages(obj, topic, MCOSParts);
    else
        resolveWithMCOSPackages(obj, MCOSParts);
    end
end

function resolveWithoutMCOSPackages(obj, topic, MCOSParts)
    
    if isempty(MCOSParts.method)
        allPackageInfo = matlab.internal.language.introspective.hashedDirInfo(topic, obj.isCaseSensitive);
        obj.resolvePackageInfo(allPackageInfo, true);
    else
        allPackageInfo = matlab.internal.language.introspective.hashedDirInfo([MCOSParts.path '@' MCOSParts.class], obj.isCaseSensitive);

        for i = 1:length(allPackageInfo)

            packageInfo = allPackageInfo(i);
            packagePath = packageInfo.path;            
            packageName = matlab.internal.language.introspective.getPackageName(packagePath);
            
            % Correct the case for subsequent uses of this data
            MCOSParts.class = matlab.internal.language.introspective.extractCaseCorrectedName(packagePath, MCOSParts.class);

            [isDocumented, packageID] = obj.isDocumentedPackage(packageInfo, packageName);

            if isDocumented || ischar(packageID)
                % MCOS or OOPS class or UDD package
                [fixedName, foundTarget, fileType] = matlab.internal.language.introspective.extractFile(packageInfo, MCOSParts.method, obj.isCaseSensitive, MCOSParts.ext);
                if foundTarget
                    % MCOS or OOPS class/method or UDD packaged function
                    if strcmp(MCOSParts.class, fixedName)
                        obj.classInfo = matlab.internal.language.introspective.classInformation.simpleMCOSConstructor(MCOSParts.class, fullfile(packagePath, [MCOSParts.class, fileType]), obj.justChecking);
                    elseif isDocumented
                        obj.classInfo = matlab.internal.language.introspective.classInformation.packagedFunction(MCOSParts.class, packagePath, fixedName, fileType);
                    else
                        classHandle = matlab.internal.language.introspective.classWrapper.rawMCOS(fixedName, fileType, packagePath, '', false, false, obj.isCaseSensitive);
                        obj.classInfo = matlab.internal.language.introspective.classInformation.fileMethod(classHandle, MCOSParts.class, packagePath, packagePath, fixedName, fileType, '');
                        obj.classInfo.setAccessible;
                    end
                    return;
                end
            end
        end
    end
end

function resolveWithMCOSPackages(obj, MCOSParts)

    inputClassName = MCOSParts.class;
    methodName     = MCOSParts.method;
    
    packagePath    = [MCOSParts.path MCOSParts.packages];
    allPackageInfo = matlab.internal.language.introspective.hashedDirInfo(packagePath, obj.isCaseSensitive);
        
    if isempty(inputClassName) && isempty(methodName)
        if ~isempty(allPackageInfo)
            % MCOS Package
            obj.classInfo = matlab.internal.language.introspective.classInformation.package(allPackageInfo(1).path, true);
        end
        return;
    end

    isUnspecifiedConstructor = isempty(methodName);
    if isUnspecifiedConstructor
        methodName = inputClassName;
    end

    for i = 1:length(allPackageInfo)

        packageInfo     = allPackageInfo(i);
        packagePath     = packageInfo.path;
        packageName     = matlab.internal.language.introspective.getPackageName(packagePath);
        className       = '';
        classHasNoAtDir = false;

        if ~isempty(inputClassName)
            
            classIndex = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, packageInfo.classes, inputClassName);
            
            if any(classIndex)
                className = packageInfo.classes{classIndex};
            end
        elseif ~isUnspecifiedConstructor
            
            [className, foundTarget, fileType] = matlab.internal.language.introspective.extractFile(packageInfo, methodName, obj.isCaseSensitive, MCOSParts.ext);

            if foundTarget
                if ~matlab.internal.language.introspective.isClassMFile(fullfile(packagePath, className))
                    obj.classInfo = matlab.internal.language.introspective.classInformation.packagedFunction(packageName, packagePath, className, fileType);
                    return;
                end
                classHasNoAtDir = true;
                  
            elseif ~isempty(MCOSParts.ext)
                packageList = dir(fullfile(packagePath, ['*' MCOSParts.ext]));
                itemIndex   = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, {packageList.name}, [MCOSParts.method MCOSParts.ext]);

                if any(itemIndex)
                    itemFullName = packageList(itemIndex).name;
                    itemName     = itemFullName(1:end-length(MCOSParts.ext));
                    
                    [~,~, ext] = fileparts(itemFullName);
                    helpFunction = matlab.internal.language.introspective.getHelpFunction(ext);

                    obj.classInfo = matlab.internal.language.introspective.classInformation.packagedUnknown(packageName, packagePath, itemName, itemFullName, helpFunction);
                    return;
                end
            end
        end

        if ~isempty(className)
            classHandle   = matlab.internal.language.introspective.classWrapper.rawMCOS(className, '', packagePath, packageName, classHasNoAtDir, true, obj.isCaseSensitive);
            obj.classInfo = classHandle.getClassInformation(methodName, obj.justChecking);
            
            if ~isempty(obj.classInfo)
                return;
            end
        end
    end
end

%   Copyright 2013 The MathWorks, Inc
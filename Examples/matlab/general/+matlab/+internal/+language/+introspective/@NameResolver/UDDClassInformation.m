function UDDClassInformation(obj, UDDParts)

    packagePath    = [UDDParts.path UDDParts.package];
    inputClassName = UDDParts.class(2:end);
    methodName     = UDDParts.method;

    if isempty(methodName)
        methodName = inputClassName;
    end

    allPackageInfo = matlab.internal.language.introspective.hashedDirInfo(packagePath, obj.isCaseSensitive);
    
    for i = 1:length(allPackageInfo)
        
        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = matlab.internal.language.introspective.getPackageName(packagePath);
        
        [isDocumented, packageID] = obj.isDocumentedPackage(packageInfo, packageName);
        
        if isDocumented
            classIndex = matlab.internal.language.introspective.casedStrCmp(obj.isCaseSensitive, packageInfo.classes, inputClassName);
            if any(classIndex)
                className = packageInfo.classes{classIndex};
                
                classHandle   = matlab.internal.language.introspective.classWrapper.rawUDD(className, packagePath, packageID, true);
                obj.classInfo = classHandle.getClassInformation(methodName, obj.justChecking);
                                
                if ~isempty(obj.classInfo)
                    return;
                end
            end
        end
    end
end

%   Copyright 2013 The MathWorks, Inc
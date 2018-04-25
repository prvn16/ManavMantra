function resolvePackageInfo(obj, allPackageInfo, isExplicitPackage)

    for i = 1:length(allPackageInfo)

        packageInfo = allPackageInfo(i);
        packagePath = packageInfo.path;
        packageName = matlab.internal.language.introspective.getPackageName(packagePath);

        [isDocumented, packageID] = obj.isDocumentedPackage(packageInfo, packageName);

        if isDocumented
            % Package
            obj.classInfo = matlab.internal.language.introspective.classInformation.package(packagePath, isExplicitPackage);
            return;
        elseif ischar(packageID) && ~isempty(regexp(packagePath, '.*[\\/]@\w*$', 'once'));
            % MCOS or OOPS Class
            obj.classInfo = matlab.internal.language.introspective.classInformation.fullConstructor([], '', packageName, packagePath, false, true, obj.justChecking);
            return;
        end
    end
end

%   Copyright 2013 The MathWorks, Inc
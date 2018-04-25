function [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName)

    packageID    = packageName;
    isDocumented = ~isempty(regexp(packageInfo.path, '.*[\\/]\+\w*$', 'once'));

    if ~isDocumented && (~isempty(packageInfo.classes) || any(strcmpi(packageInfo.m, 'schema.m')))
        packageID = findpackage(packageName);
        isDocumented = ~isempty(packageID);
    end
end

%   Copyright 2013 The MathWorks, Inc
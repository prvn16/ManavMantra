classdef fullConstructor < matlab.internal.language.introspective.classInformation.fileConstructor
    properties (SetAccess=private, GetAccess=private)
        isUnspecified = false;
    end

    methods
        function ci = fullConstructor(classWrapper, packageName, className, basePath, noAtDir, isUnspecified, justChecking)
            pathInfo = matlab.internal.language.introspective.hashedDirInfo(basePath);
            [~, ~, fileType] = matlab.internal.language.introspective.extractFile(pathInfo(1), className, true);
            if isempty(fileType)
                fullPath = basePath;
            else
                fullPath = fullfile(basePath, [className fileType]);
            end
            ci@matlab.internal.language.introspective.classInformation.fileConstructor(packageName, className, basePath, fullPath, noAtDir, justChecking);
            ci.classWrapper = classWrapper;
            ci.isUnspecified = isUnspecified;
        end

        function b = isClass(ci)
            if ci.noAtDir
                b = ci.isMCOSClassOrConstructor;
            else
                b = ci.isUnspecified;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

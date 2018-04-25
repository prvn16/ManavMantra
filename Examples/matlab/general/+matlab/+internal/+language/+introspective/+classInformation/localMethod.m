classdef localMethod < matlab.internal.language.introspective.classInformation.method
    methods
        function ci = localMethod(classWrapper, className, basePath, classMFile, derivedPath, derivedClass, methodName, packageName)
            definition = fullfile(basePath, [className filemarker methodName]);
            minimalPath = fullfile(derivedPath, [derivedClass filemarker methodName]);
            ci@matlab.internal.language.introspective.classInformation.method(classWrapper, packageName, className, methodName, definition, minimalPath, classMFile);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.

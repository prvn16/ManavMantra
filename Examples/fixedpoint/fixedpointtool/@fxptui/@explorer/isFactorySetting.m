function b = isFactorySetting(h, BAEName)
%ISFACTORYSETTING True if the object is FactorySetting
%   OUT = ISFACTORYSETTING(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.


b = false;
[factoryNames, ~] = getFactoryShortcutNames(h);
for i = 1:length(factoryNames)
    if strcmp(BAEName, factoryNames{i})
        b = true;
        return;
    end
end

% [EOF]

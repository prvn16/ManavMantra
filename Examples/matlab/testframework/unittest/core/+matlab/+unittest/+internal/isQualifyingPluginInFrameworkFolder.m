function mask = isQualifyingPluginInFrameworkFolder(files)
% This function is undocumented.

%  Copyright 2015 MathWorks, Inc.

frameworkFolder = matlab.unittest.internal.getFrameworkFolder;
pluginLocationRegex = ['^', regexptranslate('escape',[frameworkFolder, filesep])];
mask = ~cellfun(@isempty, regexp(files, pluginLocationRegex));
mask(mask) = cellfun(@isQualifyingPluginSubclass, files(mask));
end

function bool = isQualifyingPluginSubclass(filename)
import matlab.unittest.internal.getParentNameFromFilename;

parentName = getParentNameFromFilename(filename);
cls = meta.class.fromName(parentName);
bool =  ~isempty(cls) && ...
    cls< ?matlab.unittest.plugins.QualifyingPlugin;
end


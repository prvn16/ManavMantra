function parentName = getParentNameFromFilename(filename)

% This function assumes that the file corresponding to the filename is not
% in private folder

% Copyright 2014-2017 The MathWorks, Inc.

[folder, shortName] = fileparts(filename);
folder = [filesep, folder]; % Handle relative path that starts with package folder
packagePrefix = '';

packageIdx = strfind(folder, [filesep, '+']);
classIdx = strfind(folder, [filesep, '@']);

if ~isempty(classIdx)
    shortName = folder(classIdx(1)+2:end);
end

if ~isempty(packageIdx)
    packagePortion = folder(packageIdx(1)+2:end);
    if ~isempty(classIdx)
        packagePortion = folder(packageIdx(1)+2:classIdx-1);
    end
    packagePrefix = [strrep(packagePortion, [filesep, '+'], '.'), '.'];
end

parentName = [packagePrefix, shortName];
end




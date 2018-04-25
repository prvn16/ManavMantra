function filename = getFilenameFromParentName(parentName)
% This function is undocumented and may change in a future release.

% Return a relative filename (with no extension) for a parent name that
% possibly contains packages.

% Copyright 2015 The MathWorks, Inc.

dotIndex = strfind(parentName, '.');
if isempty(dotIndex) %#ok<STREMP>
    filename = parentName;
else
    lastDotIndex = dotIndex(end);
    packages = parentName(1:lastDotIndex-1);
    packages = strrep(packages, '.', [filesep, '+']);
    filename = ['+', packages, filesep, parentName(lastDotIndex+1:end)];
end

end


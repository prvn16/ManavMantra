function fullFileOrFolder = parentFolderResolver(fileOrFolder)
% This function is undocumented and may change in a future release.

% This function validates that the parent folder of the provided file or
% folder exists and resolves it to a full path. Note that the relative file
% or folder itself does not need to exist.

%  Copyright 2017 The MathWorks, Inc.

validateattributes(fileOrFolder,{'char','string'},{'scalartext'});
fileOrFolder = char(fileOrFolder);

if exist(fileOrFolder,'dir')==7 %Needed to resolve '..'
    [isAvailableFromPWD,folderInfo] = fileattrib(fileOrFolder);
    if isAvailableFromPWD
        fileOrFolder = folderInfo.Name;
    end
end
fileOrFolder = regexprep(fileOrFolder,'[\\\/]$','');
[parentFolder, remainingPart1, remainingPart2] = fileparts(fileOrFolder);
if isempty(parentFolder)
    parentFolder = '.';
end
parentFolder = matlab.unittest.internal.folderResolver(parentFolder);
fullFileOrFolder = fullfile(parentFolder,[remainingPart1, remainingPart2]);
end

% LocalWords:  scalartext

function env = createConditionallyKeptFolderEnvironment(folder)
% This function is undocumented and may change in a future release.

% Copyright 2016 MathWorks Inc.
env = [];
folder = char(folder);
if ~isdir(folder)
    mkdir(folder);
    env = onCleanup(@() deleteFolderIfEmpty(folder));
end
end


function deleteFolderIfEmpty(folder)
output = dir(folder);
if all(ismember({output.name},{'.','..'})) %if folder is empty
    rmdir(folder);
end
end
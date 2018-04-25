% Copyright 2018 The MathWorks Inc.

function removeFromMatlabPath(foldersArray)

% Ignore warning if not found in path
w = warning('off','MATLAB:rmpath:DirNotFound');
clean = onCleanup(@()warning(w));

for folder = 1:size(foldersArray)
    folderEntry = char(foldersArray(folder, :));
    rmpath(folderEntry);
end
end
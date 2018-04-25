% Copyright 2017-2018 The MathWorks Inc.

function removeFromJavaClasspath(foldersArray)

% Ignore warning if not found in path
w = warning('off','MATLAB:GENERAL:JAVARMPATH:NotFoundInPath');
clean = onCleanup(@()warning(w));

for folder = 1:size(foldersArray)
    folderEntry = char(foldersArray(folder, :));
    javarmpath(folderEntry);
end
end
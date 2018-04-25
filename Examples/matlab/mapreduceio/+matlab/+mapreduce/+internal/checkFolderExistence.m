function checkFolderExistence(folder)
%checkFolderExistence Checks if the folder exists, throws an error if not.

%   Copyright 2014 The MathWorks, Inc.
if exist(folder, 'dir') ~= 7
    reasonMsg = message('MATLAB:mapreduceio:mapreduce:noFolder');
    error(message('MATLAB:mapreduceio:serialmapreducer:folderNotForWriting',...
        folder, getString(reasonMsg)));
end

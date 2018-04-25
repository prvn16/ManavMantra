function validateFolderForWriting(folder)
%VALIDATEFOLDERFORWRITING Validates a local folder for writing.
%   Check if the given local folder exists, if so, try to open
%   a file in it. If the folder does not exist, try to create it.
%
%   See also datastore, mapreduce, tall.

%   Copyright 2016 The MathWorks, Inc.
    if ~exist(folder, 'dir')
        [s, errmsg] = mkdir(folder);
        if ~s
            error(message('MATLAB:mapreduceio:serialmapreducer:createFolderFailed',...
                folder, errmsg));
        end
    else
        testF = fullfile(folder, 'testFile');
        [fh, errmsg] = fopen(testF, 'a');
        if fh == -1
            error(message('MATLAB:mapreduceio:serialmapreducer:folderNotForWriting',...
                folder, errmsg));
        end
        fclose(fh);
        delete(testF);
    end
end

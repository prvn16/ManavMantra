function result = isClassDirectory(folderPath)
    % isClassDirectory - checks to see if enclosing folder is
    % an @-class directory.

    % Copyright 2009 The MathWorks, Inc.
    result = false;
    
    [~, parentDirName] = fileparts(folderPath);
    
    if ~isempty(parentDirName) && parentDirName(1) == '@'
        result = true;
    end
end
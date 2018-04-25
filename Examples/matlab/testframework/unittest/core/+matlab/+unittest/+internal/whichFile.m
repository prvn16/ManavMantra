function file = whichFile(file)
    % This function is undocumented.
    
    %  Copyright 2014 The MathWorks, Inc.

if strcmp(file, 'file')
    clear file;
    file = which('file');
else
    file = which(file);
end
function [fullFile,toDelete] = resolvePath(base,src)
%resolvePath Resolve absolute paths, relative paths, and URLs.
%   [fullFile,toDelete] = resolvePath(base,src)

% Matthew J. Simoneau
% Copyright 1984-2010 The MathWorks, Inc.

if regexp(src,'^(https?|ftp):')
    fullFile = tempname;
    urlwrite(src,fullFile);
    toDelete = fullFile;
else
    fileSrc = java.io.File(src);
    if fileSrc.isAbsolute
        fullFile = src;
    else
        fullFile = fullfile(fileparts(base),src);
    end
    toDelete = [];
end
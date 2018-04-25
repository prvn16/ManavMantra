function fullPathToFile = locateFile(file)
% LOCATEFILE Resolve a filename to an absolute location.
%   LOCATEFILE(FILE) returns the absolute path to FILE.  If FILE cannot be
%   found, it returns an empty string.

% Matthew J. Simoneau, November 2003
% Copyright 1984-2015 The MathWorks, Inc.

% Checking that the length is exactly one in the first two checks automatically
% excludes directories, since directory listings always include '.' and '..'.

if (length(dir(fullfile(pwd,file))) == 1)
    % Relative path.
    fullPathToFile = fullfile(pwd,file);
elseif (length(dir(file)) == 1)
    % Absolute path.
    fullPathToFile = file;
elseif ~isempty(safeWhich(file))
    % An m-file on the path.
    fullPathToFile = safeWhich(file);
else
    fullPathToFile = '';
end

function p = pathsep
%PATHSEP Path separator for this platform.
%   F = PATHSEP returns the path separator character for this platform.
%   The path separator is the character that separates directories in
%   the MATLABPATH variable.
%
%   See also PATH, FILESEP, FULLFILE.

%   Copyright 1984-2003 The MathWorks, Inc.

if strncmp(computer,'PC',2)
  p = ';';
else % isunix
  p = ':';
end

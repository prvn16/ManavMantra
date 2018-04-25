%DIR List folder.
%   DIR NAME lists the files in a folder. Pathnames and 
%   asterisk wildcards may be used. A single asterisk in the path touching 
%   only file separators will represent exactly one folder name. A 
%   single asterisk at the end of an input will represent any filename. An 
%   asterisk followed or preceded by characters will resolve to zero or 
%   more characters. A double asterisk can only be used in the path and 
%   will represent zero or more folder names. It cannot touch a character
%   other than a file separator. For example, DIR *.m lists all files with 
%   a .m extension in the current folder. DIR */*.m lists all files with
%   a .m extension exactly one folder under the current folder. 
%   DIR **/*.m lists all files with a .m extension zero or more folders 
%   under the current folder.
%
%   D = DIR('NAME') returns the results in an M-by-1
%   structure with the fields: 
%       name        -- Filename
%       folder      -- Absolute path
%       date        -- Modification date
%       bytes       -- Number of bytes allocated to the file
%       isdir       -- 1 if name is a folder and 0 if not
%       datenum     -- Modification date as a MATLAB serial date number.
%                   This value is locale-dependent.
%
%   See also WHAT, CD, TYPE, DELETE, LS, RMDIR, MKDIR, DATENUM.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

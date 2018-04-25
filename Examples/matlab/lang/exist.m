%EXIST  Check existence of variable, script, function, folder, or class
%   EXIST(NAME) returns:
%     0 if NAME does not exist
%     1 if NAME is a variable in the workspace
%     2 if NAME is a file with extension .m, .mlx, or .mlapp, or NAME
%       is the name of a file with a non-registered file extension 
%       (.mat, .fig, .txt).
%     3 if NAME is a MEX-file on the MATLAB search path
%     4 if NAME is a Simulink model or library file on the MATLAB search path
%     5 if NAME is a built-in MATLAB function. This does not include classes
%     6 if NAME is a P-code file on the MATLAB search path
%     7 if NAME is a folder
%     8 if NAME is a class (EXIST returns 0 for Java classes if you
%       start MATLAB with the -nojvm option.)
%
%   EXIST('NAME','builtin') checks only for built-in functions.
%   EXIST('NAME','class') checks only for classes.
%   EXIST('NAME','dir') checks only for folders.
%   EXIST('NAME','file') checks for files or folders.
%   EXIST('NAME','var') checks only for variables.
%
%   NAME can include a partial path, but must be in a folder on the search
%   path, or in the current folder. Otherwise, name must include a full path.
%
%   If NAME specifies a file with a non-registered file extension 
%   (.mat, .fig, .txt), include the extension.
%
%   NAME is case insensitive on Windows systems, and case sensitive for 
%   files and folder on UNIX systems.
%
%   MATLAB does not examine the contents or internal structure of a file 
%   and relies solely on the file extension for classification.
%
%   See also DIR, WHAT, ISEMPTY, PARTIALPATH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

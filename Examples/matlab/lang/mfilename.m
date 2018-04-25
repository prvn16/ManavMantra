%MFILENAME Name of currently executing MATLAB code file.
%   MFILENAME returns a character vector containing the name of the most
%   recently invoked MATLAB code file. When called from within a file,
%   it returns the name of that file. This allows the file to determine
%   its name, even if the filename has been changed.
%
%   P = MFILENAME('fullpath') returns the full path and name of the
%   MATLAB code file in which the call occurs, without the extension. 
%
%   C = MFILENAME('class') in a method returns the class of the method
%   (not including the "@").  If called from a non-method, it yields
%   the empty string.
%
%   If MFILENAME is called with any argument other than the above two,
%   it behaves as if it were called with no argument.
%
%   When called from the command line, MFILENAME returns 
%   an empty character vector.
%
%   To get the names of the callers of a MATLAB function file use
%   DBSTACK with an output argument.
%
%   See also DBSTACK, FUNCTION, NARGIN, NARGOUT, INPUTNAME.

%   Copyright 1984-2016 The MathWorks, Inc. 

%   Built-in function

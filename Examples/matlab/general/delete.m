%DELETE Delete file or graphics object.
%   DELETE file_name  deletes the named file from disk.  Wildcards
%   may be used.  For example, DELETE *.p deletes all P-files from the
%   current directory. 
%
%   Use the functional form of DELETE, such as DELETE('file') when the
%   file name is stored as a character vector or string scalar.
%
%   DELETE checks the status of the RECYCLE option to determine whether
%   the file should be moved to the recycle bin on PC and Macintosh,
%   moved to a temporary folder on Unix, or deleted.  
%
%   DELETE(H) deletes the graphics object with handle H. If the object
%   is a window, the window is closed and deleted without confirmation.
%
%   See also RECYCLE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

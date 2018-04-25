function rename(h,oldname,newname)
%RENAME Rename a file on an FTP site.
%    RENAME(FTP,OLDNAME,NEWNAME) renames a file on an FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.

% Make sure we're still connected.
connect(h)

h.jobject.rename(oldname,newname);

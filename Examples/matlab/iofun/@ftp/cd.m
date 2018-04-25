function newDir = cd(h,str)
%CD Change current working directory.
%   CD(FTP,'DIRECTORY') sets the current directory to the one specified.
%   CD(FTP,'..') moves to the directory above the current one.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.

% Make sure we're still connected.
connect(h)

if (nargin > 1)
    str = ensureChar(str);
    isSuccess = h.jobject.changeWorkingDirectory(str);
    if ~isSuccess
        error(message('MATLAB:ftp:NoSuchDirectory', str))
    end
end
newDir = char(h.jobject.printWorkingDirectory);
% There isn't an easier way to set the value of a StringBuffer.
h.remotePwd.setLength(0);
h.remotePwd.append(newDir);

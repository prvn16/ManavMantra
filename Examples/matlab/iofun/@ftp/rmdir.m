function rmdir(h,dirname)
%rmdir Remove a directory on an FTP site.
%    RMDIR(FTP,DIRECTORY) removes a directory on an FTP site.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2012 The MathWorks, Inc.

% Make sure we're still connected.
connect(h)
dirname = ensureChar(dirname);
status = h.jobject.removeDirectory(dirname);
if (status == 0)
    code = h.jobject.getReplyCode;
    switch code
        case 550
            error(message('MATLAB:ftp:DeleteFailed',dirname));
        otherwise
            error(message('MATLAB:ftp:FTPError',code))
    end
end

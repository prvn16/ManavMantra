function location = mget(h,str,targetDirectory)
%MGET Download from an FTP site.
%    MGET(FTP,FILENAME) downloads a file.
%
%    MGET(FTP,DIRECTORY) downloads a directory and its contents.
%
%    MGET(FTP,WILDCARD) downloads a set of files or directories specified
%    by a wildcard.
%
%    MGET(...,TARGETDIRECTORY) specifies the local target directory, rather
%    than the current directory.

% Copyright 1984-2017 The MathWorks, Inc.

% Make sure we're still connected.
connect(h)
str = ensureChar(str);

if (nargin < 3)
    targetDirectory = pwd;
else
    targetDirectory = ensureChar(targetDirectory);
end

% Set ascii/binary
switch char(h.type.toString)
    case 'binary'
        h.jobject.setFileType(h.jobject.BINARY_FILE_TYPE);
    otherwise
        h.jobject.setFileType(h.jobject.ASCII_FILE_TYPE);
end

if any(str == '*')
    list = h.jobject.listNames(str);
    listing = cell(size(list));
    for i = 1:length(list)
        listing{i} = char(list(i));
    end
else
    listing = {str};
end

iListing = 0;
location = {};
while iListing < length(listing)
    iListing = iListing+1;
    name = char(listing(iListing));
    localName = strrep(fullfile(targetDirectory,name),'/',filesep);

    % Where should we save this file?
    fileObject = java.io.File(localName);

    % Are we trying to overwrite a local file we can't change?
    if fileObject.exists && ~fileObject.delete
        error(message('MATLAB:ftp:CannotOverwrite', localName))
    end

    % Are we trying to write a local file where we don't have permission?
    try
        d = java.io.File(fileparts(localName));
        d.mkdirs;
        canOpen = fileObject.createNewFile;
    catch
        canOpen = false;
    end
    if ~canOpen
        error(message('MATLAB:ftp:CannotCreate', localName));
    end

    % Download the file.
    fos = java.io.FileOutputStream(fileObject);
    try
        h.jobject.retrieveFile(name,fos);
    catch
        replyCodeHelper(h,fos,fileObject,name,localName,location,listing);
    end
    % if exception was not thrown, close the connection
    fschange(fileparts(localName));
    [location,listing] = replyCodeHelper(h,fos,fileObject,name,localName,location,listing);
end
end

function [location, listing] = replyCodeHelper(h,fos,fileObject,name,localName,location,listing)
% close the FTP connection
fos.close;
% Did it work?
replyCode = h.jobject.getReplyCode;
switch replyCode
    case 226
        % "Closing data connection. Requested file action successful."
        % Build the list of files uploaded.
        location{end+1,1} = localName;
    case 550
        % "Requested action not taken.  File unavailable."
        fileObject.delete;

        % Couldn't find a file with that name.  Try a directory.
        currentDir = cd(h);
        try
            cd(h,name);
            isDir = true;
        catch
            isDir = false;
        end
        cd(h,currentDir);
        if isDir
            mkdir(localName);
            d = dir(h,name);
            for i = 1:length(d)
                next = d(i).name;
                if isequal(next,'.') || isequal(next,'..')
                    % skip
                else
                    listing{end+1} = [name '/' next];
                end
            end
        else
            error(message('MATLAB:ftp:FileUnavailable', name));
        end
    otherwise
        error(message('MATLAB:ftp:FTPError',replyCode));
end
end

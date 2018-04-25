function location = mput(h,str)
%MPUT Upload to an FTP site.
%    MPUT(FTP,FILENAME) uploads a file.
%
%    MPUT(FTP,DIRECTORY) uploads a directory and its contents.
%
%    MPUT(FTP,WILDCARD) uploads a set of files or directories specified
%    by a wildcard.
%
%    All of these calling forms return a cell array listing the full path to the
%    uploaded files on the server.

% Copyright 1984-2017 The MathWorks, Inc.

% Make sure we're still connected.
connect(h)
str = ensureChar(str);
% Figure out where the files live.
[localDir,file,ext] = fileparts(str);
filename = [file ext];
if isempty(localDir)
    localDir = pwd;
end
remoteDir = char(h.jobject.printWorkingDirectory);

% Set ascii/binary
switch char(h.type.toString)
    case 'binary'
        h.jobject.setFileType(h.jobject.BINARY_FILE_TYPE);
    otherwise
        h.jobject.setFileType(h.jobject.ASCII_FILE_TYPE);
end

if contains(filename,'*')
    % Upload any files and directories that match the wildcard.
    d=dir(fullfile(localDir,filename));
    listing = {d.name};
else
    listing = {filename};
end

location = {};
iListing = 0;
while (iListing < length(listing))
    iListing = iListing+1;
    name = listing{iListing};
    localName = strrep(fullfile(localDir,name),'/',filesep);
    if isdir(localName)
        mkdir(h,name);
        d = dir(localName);
        for i = 1:length(d)
            next = d(i).name;
            if isequal(next,'.') || isequal(next,'..')
                % skip
            else
                listing{end+1} = [name '/' next];
            end
        end
    else
        % Check for the file.
        fileObject = java.io.File(localName);
        if ~fileObject.exists
            error(message('MATLAB:ftp:NotFound', localName))
        end

        % Upload this file.
        fis = java.io.FileInputStream(fileObject);
        try
            status = h.jobject.storeFile(name,fis);
        catch
            fis.close;
            close(h);
            connect(h);
            % call error handler routine to check for proper error code
            errorHandler(h,name);
        end
        fis.close;
        if status
            % Build the list of files uploaded.
            location{end+1,1} = [remoteDir '/' name];
        else
            % call error handler routine since the upload failed
            errorHandler(h,name);
        end
    end
end
end

function errorHandler(h,name)
% Error if the upload failed.
code = h.jobject.getReplyCode;
switch code
    case 550
        error(message('MATLAB:ftp:UploadFailed', name));
    case 553
        error(message('MATLAB:ftp:BadFilename', name));
    otherwise
        error(message('MATLAB:ftp:FTPError',code));
end
end


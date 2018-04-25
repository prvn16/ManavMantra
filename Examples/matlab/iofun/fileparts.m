function [pathstr, name, ext] = fileparts(file)
%FILEPARTS Filename parts.
%   [FILEPATH,NAME,EXT] = FILEPARTS(FILE) returns the path, file name, and file name
%   extension for the specified FILE. The FILE input is the name of a file or folder,
%   and can include a path and file name extension. The function interprets all
%   characters following the right-most path delimiter as a file name plus extension.
%
%   If the FILE input consists of a folder name only, be sure that the right-most
%   character is a path delimiter (/ or \). Othewise, FILEPARTS parses the trailing
%   portion of FILE as the name of a file and returns it in NAME instead of in
%   FILEPATH.
%
%   FILEPARTS only parses file names. It does not verify that the file or folder
%   exists. 
%
%   To reconstruct a file name from the output of FILEPARTS, use STRCAT to 
%   concatenate the file name and the extension that begins with a period (.) 
%   without a path separator. Then, use FULLFILE to build the file name with 
%   the platform-dependent file separators where necessary. 
%   For example, fullfile(filepath, strcat(name,ext)).
%
%   FILEPARTS is platform dependent. On Microsoft Windows systems, you can 
%   use either forward (/) or back (\) slashes as path delimiters, even within 
%   the same path. On Unix and Macintosh systems, use only / as a delimiter.
%
%   See also FULLFILE, PATHSEP, FILESEP.

%   Copyright 1984-2017 The MathWorks, Inc.

pathstr = '';
name = '';
ext = '';
inputWasString = false;


if ~ischar(file) && ~isStringScalar(file)
    error(message('MATLAB:fileparts:MustBeChar'));
elseif isempty(file)
    return;
elseif ~isrow(file)
    error(message('MATLAB:fileparts:MustBeChar'));
end

if isstring(file)
    inputWasString = true;
    file = char(file);
end

if ispc
    ind = find(file == '/'|file == '\', 1, 'last');
    if isempty(ind)
        ind = find(file == ':', 1, 'last');
        if ~isempty(ind)       
            pathstr = file(1:ind);
        end
    else
        if ind == 2 && (file(1) == '\' || file(1) == '/')
            %special case for UNC server
            pathstr =  file;
            ind = length(file);
        else 
            pathstr = file(1:ind-1);
        end
    end
    if isempty(ind)       
        name = file;
    else
        if ~isempty(pathstr) && pathstr(end)==':' && ...
                (length(pathstr)>2 || (length(file) >=3 && file(3) == '\'))
                %don't append to D: like which is volume path on windows
            pathstr = [pathstr '\'];
        elseif isempty(deblank(pathstr))
            pathstr = '\';
        end
        name = file(ind+1:end);
    end
else    % UNIX
    ind = find(file == '/', 1, 'last');
    if isempty(ind)
        name = file;
    else
        pathstr = file(1:ind-1); 

        % Do not forget to add filesep when in the root filesystem
        if isempty(deblank(pathstr))
            pathstr = '/';
        end
        name = file(ind+1:end);
    end
end

if ~isempty(name)
    % Look for EXTENSION part
    ind = find(name == '.', 1, 'last');
    
    if ~isempty(ind)
        ext = name(ind:end);
        name(ind:end) = [];
    end
end

if inputWasString
    pathstr = string(pathstr);
    name = string(name);
    ext = string(ext);
end

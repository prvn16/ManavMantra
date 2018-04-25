function [privateFiles, privateDirName] = getPrivateFiles(dirname)

persistent privateDirCache

%getPrivateFiles  Get list of files in private directory
%    privateFiles = getPrivateFiles(DIR_NAME) returns a cell array
%    of file names in a private directory under the input directory
%    name, if a private directory exists.  If DIR_NAME is itself  
%    a private directory, privateFiles will be a cell array of file
%    names in DIR_NAME.  This relies on MATLAB not recognizing a 
%    private directory within a private directory.  DIR_NAME must 
%    be a string specifying either a relative or an absolute 
%    directory name.  If no private directory exists under DIR_NAME
%    (or if DIR_NAME is not itself a private directory), an empty 
%    cell array is returned.  Only files with .m and platform-
%    correct MEX extensions are included, but the extensions are 
%    removed.
    
    if nargin == 0
        privateDirCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
    else
        fs = filesep;
        privateSuffix = ['\' fs 'private' '\' fs '$'];
        %Check if this directory is itself private or has a private
        %subdirectory.
        if ~isempty(regexp(dirname, privateSuffix, 'ONCE'))
            privateFound = true;
            % remove the filesep at the end
            privateDirName = dirname(1:end-1);
        else
            privateDirName = fullfile(dirname,'private');
            privateFound = ...
                matlab.depfun.internal.cacheExist(privateDirName, 'dir');
        end
        if (privateFound)
            if isKey(privateDirCache, privateDirName)
                privateFiles = privateDirCache(privateDirName);
            else
                privateFiles = getDirContents(privateDirName);
                privateDirCache(privateDirName) = privateFiles;
            end
        else
            privateFiles = {};
        end
    end

classdef FileConsumer < matlab.net.http.io.ContentConsumer
% FileConsumer Consumer for files in HTTP messages.
%   This ContentConsumer provides a convenient way to download a file from a web
%   service, or to save data received from the web in a file. You can specify
%   the name of the file, or it can let MATLAB determine the name from
%   information sent by the server or file named in the URI.
%
%   To use a FileConsumer in its simplest form, specify it as the third argument to 
%   RequestMessage.send:
%
%      import matlab.net.http.*, import matlab.net.http.field.*, import matlab.net.http.io.*
%      consumer = FileConsumer;
%      req = RequestMessage;
%      resp = req.send(url,[],consumer);
%      filename = consumer.Filename;
%      % Another way to get the filename
%      filename = resp.Body.Data;
%
%   FileConsumer properties:
%      FileIdentifier - identifier of the file being written
%      Filename       - full pathname of the file being written
%
%   FileConsumer methods:
%      FileConsumer   - constructor
%
%   For subclass authors
%   --------------------
%
%   Create a subclass of FileConsumer if you want to examine the data as it is
%   being received, or modify the data prior to storing it a file. In your
%   consumer, override the putData method, modify the data if desired, and call
%   the superclass putData to write the data to the file. If you override
%   initialize or start, be sure to call the superclass methods.
%
%   Another way to process data and then save it in a file is to use delegation.
%   Create your own consumer that extends ContentConsumer, and in your
%   initialize or start method, create a FileConsumer and delegate to it using
%   the delegateTo method. In your putData method, process the data and then
%   call the FileConsumer's putData to write it to the file. When used like
%   this, you should specify a FILENAME argument to the FileConsumer
%   constructor.
%
%   FileConsumer methods for subclass authors:
%      initialize   - initialize for new message
%      start        - start transfer of data
%      putData      - save the next buffer of data
%
% See also ContentConsumer, matlab.net.http.RequestMessage,
% matlab.net.http.ResponseMessage, ContentTypeField, delegateTo, putData,
% initialize, start

% Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % FileIdentifier - identifier of the file being written
        %   If the constructor was called with an FID argument, this is that identifier.
        %   Data will be written to the current file position indicator associated with
        %   this identifier, so subclasses should be careful not to accidentally change
        %   the position when using this identifier. At conclusion of the transfer, the
        %   file remains open and the position will remain at the end of the file.
        %
        %   If the constructor was called with a FILENAME argument, or with no
        %   arguments, this is the read-only file identifier for that file. This allows
        %   subclasses to read the file during transfer without disturbing the position
        %   indicator used for writing. At the conclusion of the transfer, this
        %   identifier will be closed.
        %
        %   This property is read-only.
        %
        % See also FileConsumer.FileConsumer, Filename
        FileIdentifier double = []
        
        % Filename - full pathname of file being written
        %   If the constructor was called with a FID argument, this is the name of that
        %   file. Otherwise, this value may not be set until MATLAB has begun writing
        %   to the file during receipt of a response message, since the filename cannot
        %   necessarily be determined until all headers have been received. Use this
        %   property to determine the file that was written. This name is also stored
        %   in Response.Body.Data.
        %
        %   This property is read-only.
        %
        % See also FileConsumer.FileConsumer, FileIdentifier
        Filename string = string.empty
    end
    
    properties (Access=private)
        % Tail of filename to write or create minus extension; "" if generating a name.
        InputFilename string
        % extension of filename; "" says we generate one
        InputFilenameExt string
        % input file identifer, if specified
        InputFileID double = []
        % Parent directory of file; empty if FILENAME that user specified is an existing
        % file with extension or the user specified an FID. In this case we don't make
        % up a file name from the response. This always ends with a filesep.
        Dirname string = string.empty 
        Unique logical = false % true if InputUnique or we created 'untitled' name
        TextMode logical % true if 'T' (but not 't') specified at end of PERMISSION
        Permission string  % PERMISSION with 'u' changed to 'w'
        Literal logical = false; % true if user specified filename with extension
        Cleanup onCleanup   
        InputUnique logical = false % true if 'u' or 'u+' specified for PERMISSION 
    end

    methods 
        function obj = FileConsumer(varargin)
        % FileConsumer Consumer for reading and storing files from HTTP
        %   FILECONSUMER = FileConsumer(FILENAME, PERMISSION, MACHINEFORMAT, ENCODING)
        %   constructs a FileConsumer that will create (or overwrite) with the payload
        %   of the response from the server. The parameters have the same meaning as
        %   those of the fopen function, and all are optional. The PERMISSION, if present
        %   must allow write access. If not present, 'w+' is assumed. The following
        %   additional values of PERMISSION are supported:
        %
        %     'u', 'u+'     Same as 'w' and 'w+', but if the file already exists, then 
        %                   a new file is created with a unique name derived from
        %                   FILENAME. The FILENAME will have a hyphen and a sequence number
        %                   appended to the part of its name prior to the extension. For
        %                   example, if FILENAME is "MyFile.txt" but the file exists,
        %                   MATLAB will create a new file MyFile-1.txt. The new file's
        %                   full path name can be obtained from the Filename property.
        %     'T'           When appended to a permission, behaves similar to 't' but
        %                   uses text mode only if the Content-Type of the data
        %                   indicates it is character-based. This includes any type 
        %                   specifying a charset parameter or types MATLAB knows to be
        %                   character-based, such as application/json.
        %
        %   The FILENAME you specify is interpreted somewhat differently from fopen as
        %   follows:
        %
        %   1. FILENAME specifies a file in an existing directory; file need not exist
        %       
        %      MATLAB opens it using fopen(FILENAME,PERMISSION,...) or (if no PERMISSION
        %      specified) fopen(FILENAME,'w+'). If FILENAME has no extension, MATLAB
        %      adds an extension based on the Content-Type and/or Content-Disposition
        %      header field in the received message or the extension of the filename in
        %      the URI of the request, if any. If the FILENAME already has an
        %      extension, the name will be used as is, except that a sequence number
        %      will be inserted if PERMISSION is 'u' or 'u+'.
        %
        %   2. FILENAME specifies an existing, writable directory
        %
        %      Same as case 1, but MATLAB creates a file in the directory with a name
        %      derived from the Content-Disposition header field in the response or from
        %      the URI, possibly adding an extension based on Content-Type if that name
        %      does not contain one.
        %
        %   3. FILENAME missing or empty
        %
        %      Same as case 2, but using the current directory. This is treated as if
        %      FILENAME was '.'. Note that this will be MATLAB's current directory at
        %      the time this FileConsumer was created, not the time this consumer is used
        %      in a send request.
        %
        %   To determine the name of the file that MATLAB has created, see the Filename
        %   property.
        % 
        %   In all cases, for 'w' and 'w+' permissions (or if PERMISSION is not
        %   specified), MATLAB will not overwrite an existing file unless that file's
        %   name was exactly equal to FILENAME. For example assume you have a file
        %   called data.txt in the current directory. If you specify:
        %
        %       FileConsumer("data")
        %   
        %   and the message comes in with a Content-Type that requires a ".txt"
        %   extension, then MATLAB will try to create "data.txt". If this file already
        %   exists, MATLAB will not overwrite it. But if you explicitly specify:
        %
        %       FileConsumer("data.txt")   or   FileConsumer("data", "a+")
        %   
        %   then MATLAB will overwrite or append to the existing "data.txt". If you
        %   specify:
        %
        %      FileConsumer("data.txt","u")
        %
        %   and "data.txt" already exists, MATLAB will create "data-1.txt".
        %
        %   If you are using FileConsumer to download compressed (e.g., zipped) data and
        %   want to save it in compressed form, you may need to set
        %   HTTPOptions.DecodeResponse to false to prevent the data from being
        %   decompressed. MATLAB will normally decompress data if the server specifies a
        %   Content-Encoding header that indicates compression, though this header does
        %   not normally appear for Content-Types that are naturally compressed, such as
        %   application/zip. Servers that send zip archives do not specify compression
        %   in a Content-Encoding header.
        %
        %   FILECONSUMER = FileConsumer(FID) constructs a FileConsumer that writes to
        %   the file identifier FID. Prior to sending a message FID must be the
        %   identifier of a file you have opened for writing. MATLAB writes to this
        %   file at the current position indicator, so if you open an existing file
        %   using 'a+' permission, for example, MATLAB will append to the file. When
        %   transfer is completed, MATLAB leaves the position indicator at the end of
        %   the file and does not close the file.
        %
        % See also ContentConsumer, fopen, Filename, HTTPOptions
            import matlab.net.internal.getString
            if nargin > 0 && isa(varargin{1},'double') && ~isempty(varargin{1})
                fid = varargin{1};
                % get the full pathname and permission of file
                % this throws appropriate error if fid is not integer, etc.
                [obj.Filename, perm] = fopen(fid);
                if strlength(obj.Filename) == 0
                    error(message('MATLAB:http:FileIDNotFound', fid));
                end
                if ~contains(obj.Filename,filesep)
                    % fopen seems to have a bug in that a file opened for write doesn't return the
                    % full path
                    obj.Filename = fullfile(pwd, char(obj.Filename));
                end
                if startsWith(perm, "r")
                    error(message('MATLAB:http:FileIDNotWritable', fid));
                end
                obj.InputFileID = fid;
                obj.FileIdentifier = fid;
                return;
            end
            if nargin == 0
                % No arguments: FILENAME not specified
                filename = ".";
                permission = 'w';
            else
                % FILENAME specified
                filename = getString(varargin{1}, mfilename, 'FILENAME', true);
                if isempty(filename)
                    % an empty filename is same as .
                    filename = ".";
                else
                    % don't allow * wildcard because fileattrib uses it
                    if filename.contains('*')
                        error(message('MATLAB:http:BadFilename', filename));
                    end
                end
                if nargin > 1 
                    % PERMISSION specified; validate it and convert 'u' to 'w'
                    permission = getString(varargin{2}, mfilename, 'PERMISSION');
                    if endsWith(lower(permission),'t')
                        obj.TextMode = permission.endsWith('T');
                        permValidation = permission.extractBefore(strlength(permission));
                    else
                        permValidation = permission;
                    end
                    % We want to use validatestring for its nice error message, but it is
                    % case-insensitive and accepts leading characters only, which we don't want, so
                    % first check for valid permissions and call the function only if it's invalid.
                    validPerms = ["r+","w","a","w+","a+","W","A","u","u+"];
                    if any(strcmp(permValidation,validPerms))
                        permission = permValidation;
                    else
                        % Always error out, but also to show what string the user entered. To make that
                        % work, add space-backspace to the user's input so that it doesn't match
                        % anything, yet displays as entered.
                        permValidation = sprintf(" \b%s", permValidation);
                        validatestring(permValidation, validPerms, mfilename, 'PERMISSION');
                        assert(false)
                    end
                    obj.InputUnique = startsWith(permission, 'u');
                    if obj.InputUnique
                        permission = strrep(permission, 'u', 'w');
                    else
                    end
                    obj.Unique = obj.InputUnique;
                else
                    permission = "w+";
                end
            end
            obj.Permission = permission;
            creatingNewFile = false; % true if we think we'll need to create a new file in dir
            if ~isdir(filename)
                % FILENAME not a directory; it may or may not exist and it may be a relative
                % or absolute path
                info = dir(char(filename)); % returns empty if filename not exist
                % get the folder and filename for the file
                if isempty(info) || obj.Unique
                    % filename doesn't exist and not a directory, or it exists and Unique is
                    % specified
                    % strip off last part of the path name and see if parent directory exists
                    % parts(end) is the filename
                    parts = split(filename, {filesep '/'});
                    % get parent directory name
                    if isscalar(parts)
                        % just one segment to the name; it's not a directory so
                        % it must be the name of a file user wants to create in working dir
                        folder = '.';
                    else
                        % reassemble leading parts into a relative or absolue folder pathname
                        folder = strjoin(parts(1:end-1), filesep);
                        if ~folder.endsWith(filesep) 
                            % add '/' to folder name
                            folder = folder + filesep;
                        else
                        end
                        folder = char(folder);
                    end
                    filename = parts(end);
                    creatingNewFile = true;
                else
                    % Filename exists and it's not a directory; it may be a relative or absolute
                    % path. 
                    [~,~,ext] = fileparts(filename);
                    if strlength(ext) > 0
                        % If it has an extension, then this will be the file we write, so check if
                        % writable. If it has no extension then we may not write this file
                        % if, at download time, we decide to add an extension.
                        [status, attr] = fileattrib(char(filename));
                        assert(status ~= 0 && ~attr.directory);
                        if ~attr.UserWrite
                            error(message('MATLAB:http:FileNotWritable', filename));
                        end
                    else
                    end
                    folder = info.folder;
                    filename = info.name;
                end
                obj.Literal = true;
            else
                % FILENAME was a directory; we'll try to create a new file with a name we
                % choose later; if that name clashes with an existing file, we'll error out
                % for 'w' or 'w+' permissions
                folder = filename;
                filename = string.empty;
                creatingNewFile = true;
            end
            % folder is now an absolute or relative directory name; not checked for
            % existence
            folder = char(folder);
            [status, attr] = fileattrib(folder);
            if status == 0
                % directory doesn't exist
                error(message('MATLAB:http:DirNotFound', folder));
            end
            if creatingNewFile
                % if we're creating a new file, check if directory is writable
                assert(attr.directory)
                if ~attr.UserWrite
                    error(message('MATLAB:http:DirNotWritable', folder));
                end
            else
            end
            obj.Dirname = attr.Name;
            if ~obj.Dirname.endsWith(filesep)
                obj.Dirname = obj.Dirname + filesep;
            else
            end
            [~, obj.InputFilename, obj.InputFilenameExt] = fileparts(char(filename));
        end
        
        function [len, stop] = putData(obj, data)
        % putData Store next buffer of data
        %   [SIZE, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that MATLAB calls to store the next buffer of data read
        %   from the server. This method writes DATA to the file and returns the number
        %   of bytes written.
        %
        % See also matlab.net.http.io.ContentConsumer.putData
            if isempty(data)
                if isempty(obj.InputFileID)
                    % we opened the file, so close it
                    obj.Cleanup = onCleanup.empty;
                    obj.FileIdentifier = [];
                else
                end
                [len, stop] = obj.putData@matlab.net.http.io.ContentConsumer(data);
            else
                count = fwrite(obj.FileIdentifier, data);
                len = count;
                stop = false;
            end
        end
    end
    
    methods (Access=protected)
        function len = start(obj)
        % START start receipt of a file
        %   BUFSIZE = START(CONSUMER) is an abstract method of ContentConsumer that MATLAB
        %   calls to start receipt of data for a file.
        
            % Reset for a new file, or restarting the same file.
            obj.FileIdentifier = obj.InputFileID;
            if isempty(obj.InputFileID)
                % recompute starting pathname if FID was not an input argument to constructor
                obj.Filename = obj.InputFilename + obj.InputFilenameExt;
            end
            if ~isempty(obj.Dirname)  
                theFilename = obj.InputFilename;
                theFilenameExt = obj.InputFilenameExt;
                % creating new file, unless it already exists
                if strlength(obj.InputFilenameExt) == 0 || strlength(obj.InputFilename) == 0
                    [name, ext] = obj.getNameAndExtension();
                    if strlength(obj.InputFilename) == 0
                        theFilename = name;
                    else
                    end
                    if strlength(obj.InputFilenameExt) == 0
                        theFilenameExt = ext;
                    else
                    end
                else
                end
                filename = string(theFilename) + string(theFilenameExt);
                fullpath = obj.Dirname + filename;
                if exist(fullpath, "file") ~= 0
                    % the file we want to create already exists
                    if obj.Unique
                        % if unique requested, get a unique name that doesn't exist
                        fullpath = obj.getUniqueName(theFilename, theFilenameExt);
                    elseif (obj.Literal && strcmp(filename,obj.Filename)) || ~obj.Permission.startsWith('w')
                        % if unique not requested but the name of the file we're writing is exactly the
                        % same as the one specified in the constuructor, or the permission was something
                        % other than 'w' or 'w+', it's OK to write to it, so just make sure it's
                        % writable.
                        [status,attr] = fileattrib(char(fullpath));
                        if status == 0
                            % Directory doesn't exist. We checked this already in the constructor, but
                            % things could have changed by now.
                            error(message('MATLAB:http:DirNotFound', folder));
                        end
                        if attr.directory || ~attr.UserWrite
                            error(message('MATLAB:http:FileNotWritableOrDir', fullpath));
                        end
                    else
                        % file exists, unique not requested and not literal and permission is 'w' or 'w+'
                        if strlength(obj.Filename) > 0
                            error(message('MATLAB:http:CannotOverwrite',fullpath,obj.Filename));
                        else
                            error(message('MATLAB:http:CannotOverwriteNoName',fullpath));
                        end
                    end
                end
                obj.Filename = fullpath;
            end
            if isempty(obj.Filename) || strlength(obj.Filename) == 0
                % file name not set; possibly because user aborted start() last time before it
                % finished. In this case call recursively.
                assert(~isempty(obj.Dirname) && strlength(obj.Dirname) ~= 0)
                len = obj.start();
            else
                if isempty(obj.InputFileID)
                    % open the file, maybe creating it 
                    [obj.FileIdentifier, reason] = fopen(obj.Filename, obj.Permission);
                    if obj.FileIdentifier < 0
                        % At this point, since we checked that the directory was writable and that the
                        % file, if it exists, was overwritable, the only reason this would fail is
                        % because the directrory isn't writable.
                        error(message('MATLAB:http:CannotCreateFile', reason, obj.Filename));
                    end
                    obj.Cleanup = onCleanup(@()obj.clearall(obj.FileIdentifier));
                end
                len = [];
            end
            obj.Response.Body.Data = obj.Filename;
        end
        
        function ok = initialize(obj)
            if isempty(obj.InputFileID)
                % Clear the Filename unles a FileID was specified to the constructor.
                % This will be set to the actual file once transfer starts.
                obj.Filename = [];
            else
            end
            obj.Unique = obj.InputUnique;
            ok = true;
        end
    end 
    
    methods (Access=private)
        function [name, ext] = getNameAndExtension(obj)
        % Return the name and extension of the file we would like to create based on
        % headers and the URI being requested
            persistent subtypeToSuffixMap
            
            % first prefer the Content-Disposition field
            cdf = obj.Header.getValidField('Content-Disposition');
            if ~isempty(cdf)
                cdf = cdf(end);
                filename = cdf.getParameter('filename');
                if ~isempty(filename)
                    [~, name, ext] = fileparts(filename);
                    
                    return;
                end
            else
            end
            % if no Content-Disposition, get name and possible extension from URI
            path = obj.URI.Path;
            name = '';
            uriExt = '';
            if ~isempty(path)
                % Get last segment of path. If it's empty, it means path ends in '/' and points
                % to a directory, so we'll use "Untitled". If anything else, assume it's a file
                % name and use it for the name. This could be a wrong guess, but it's all we
                % have to go by when the user gave us no filename and there is no
                % Content-Dispostion field. For example "httpbin.org/image/png" returns a
                % Content-Type of image/png. We will assume from the URI that the filename
                % should be png and from the Content-Type the extension should be png, resulting
                % in png.png.
                filename = char(path(end));
                if ~isempty(filename)
                    [~,name,uriExt] = fileparts(filename);
                else
                end
            else
            end
            if isempty(name)
                % Use the name untitled. This doesn't need to be translated since we use this
                % name (for example, the editor) on all platforms.
                name = 'untitled';
                % Also set Unique, so we create Untitled-1, Untitled-2, etc.
                obj.Unique = true;
            else
            end
            % We have a name; now get extension. Use URI's if we have one.
            if isempty(uriExt)
                % No extension on URI, so get from Content-Type 
                ext = "";
                ctf = obj.Header.getValidField('Content-Type');
                if ~isempty(ctf)
                    type = ctf(end).convert();
                    fulltype = char(type.Type + '/' + type.Subtype);
                    [~,~,~,typeToSuffix] = matlab.net.http.internal.getTypeMaps();
                    if typeToSuffix.isKey(fulltype)
                        % if it's in our table (for image, audio, spreadsheet) use that
                        ext = typeToSuffix(char(fulltype));
                    else
                        % check some other types
                        if isempty(subtypeToSuffixMap)
                            % populate map first time
                            map = ["csv" "csv"; "xml" "xml"; "json" "json"; "html" "html"; "htm" "htm"];
                            subtypeToSuffixMap = containers.Map;
                            for i = 1 : size(map,1)
                                subtypeToSuffixMap(char(map(i,1))) = map(i,2);
                            end
                        else
                        end
                        if subtypeToSuffixMap.isKey(char(type.Subtype))
                            ext = subtypeToSuffixMap(char(type.Subtype));
                        else
                            switch(type.Type)
                                case "text"
                                    ext = "txt";
                            end
                        end
                    end
                else
                end
                if strlength(ext) ~= 0
                    ext = "." + ext;
                else
                end
            else
                ext = uriExt;
            end
        end
        
        function path = getUniqueName(obj, theFilename, theFilenameExt)
        % The path at obj.Dirname + theFilename + theFilenameExt
        % already exists. Add "-N" to theFilename repeatedly, where N=1,2,3,... until
        % the file doesn't exist anymore and return the path. If InputFilename already
        % ends in -N, start with that number
            prefix = obj.Dirname + theFilename;
            assert(exist(char(prefix + theFilenameExt), 'file') ~= 0)
            parts = regexp(prefix,'^(.*)-(\d+)$','tokens','once');
            if isempty(parts)
                index = 1;
            else
                index = str2double(parts(2));
                prefix = parts(1);
            end
            for index = index : 10000
                path = prefix + '-' + num2str(index) + theFilenameExt;
                if exist(path, 'file') == 0
                    return
                end
            end
            error(message('MATLAB:http:CannotDeriveFilename', prefix + theFilenameExt, path));
        end
    end
    
    methods (Access=private)
        function clearall(~,fid)
            if fid > 0 
                fclose(fid);
            else
            end
        end
    end
end
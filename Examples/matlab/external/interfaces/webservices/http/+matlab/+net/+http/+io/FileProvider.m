classdef FileProvider < matlab.net.http.io.ContentProvider & matlab.mixin.Copyable
% FileProvider ContentProvider that sends files
%
%   This ContentProvider is a convenient way to send a file or files to a server.
%   To send one file in a PUT message:
%
%      import matlab.net.http.*, import matlab.net.http.field.*, import matlab.net.http.io.*
%      provider = FileProvider('dir/foo.jpg');
%      req = RequestMessage(PUT,[],provider);
%      resp = req.send(url);
%
%   The provider sets the appropriate Content-Type header field in the request
%   message to the type of file derived from the filename extension, and adds a
%   Content-Disposition field naming the file. In the above example, it would
%   say "image/jpeg" with filename "foo.jpg".
%
%   To upload multiple files in a multipart/mixed message, possibly of different
%   types, create an array of FileProviders by specifying an array of filenames
%   and use this array as a delegate to a MultipartProvider:
%
%      provider = MultipartProvider(FileProvider(["foo.jpg", "bar.txt"]));
%      req = RequestMessage(PUT, [], provider);
%      resp = req.send(url);
%
%   In this case each header of the multipart message will contain a
%   Content-Type field a Content-Disposition field with a filename attribute
%   naming the file.
%
%   However in practice, most servers that accept multipart content expect it to be of
%   type "multipart/form-data", not "multipart/mixed". To send files using
%   multipart forms, use a MultipartFormProvider. That provider requires you to
%   know the "control names" for the various fields of the form, so that each part
%   is associated with the correct control. For example, if you want to send a form with
%   controls called "files" and "text", where the first accepts multiple files
%   and the second accepts just one:
%     
%      provider = MultipartFormProvider("files", FileProvider(["foo.jpg", "bar.txt"]),...
%                                       "text", FileProvider("bar.txt"));
%
%   However, some servers require you to specify multiple files by using a
%   nested form:
%
%      provider = MultipartFormProvider("files", MultipartProvider(FileProvider(["foo.jpg", "bar.txt"])),...
%                                       "text", FileProvider("bar.txt"));
%
%
%   FileProvider properties:
%     Filename     - full path of the file, derived from the input argument
%     FileSize     - number of bytes to transmit
%
%   FileProvider methods:
%     FileProvider - constructor
%
%   For subclass authors
%   --------------------
%
%   Create a subclass of FileProvider if you want to send a file, modifying it
%   on the way out. To do this, override getData to call the superclass to gain
%   access to the bytes to be sent, and possibly return different bytes.
%   Following is an example of a FileProvider that imitates what fopen's text
%   mode does on Windows but on all platforms, deleting the carriage return from all
%   carriage-return/line-feed pairs in the file, but retaining other carriage
%   returns. It needs to handle a pair that is split across buffers.
%
%   classdef CRRemover > matlab.net.http.io.FileProvider
%       properties
%           LastCR char % CR character at end of last buffer or ''
%       end
%       methods
%           function len = start(obj)
%               obj.LastCR = '';
%               len = [];
%           end
%           function [data, stop] = getData(obj, len)
%               [data, stop] = obj.getData@matlab.net.http.io.FileProvider(len);
%               chars = regexprep([obj.LastCR char(reshape(data,1,[]))], '\r\n', '\n');
%               % strip and save final character if it's a CR
%               if chars(end) == sprintf('\r') && ~stop
%                   obj.LastCR = chars(end);
%                   chars(end) = '';
%               else
%                   obj.LastCR = '';
%               end
%               data = uint8(chars);
%           end
%       end
%   end
%
%   FileProvider methods (overridden from superclass):
%     getData      - return the next buffer of data (called by MATLAB or subclasses)
%     string, show - return information about provider
%
% See also matlab.net.http.RequestMessage, MultipartProvider,
% MultipartFormProvider, matlab.net.http.MessageBody, getData, start

% Copyright 2017 The MathWorks, Inc.
    
    properties (Dependent)
        % Filename - full path of the file, derived from input argument
        %   Value is a string.
        Filename string
    end
    
    properties
        % FileSize - number of bytes to transmit
        %   At most this many bytes of the file will be sent. The default (empty) says
        %   to transmit until reaching the end of the file. 
        FileSize double
    end
    
    properties (Access=private)
        RealFile string = string.empty
        BytesSent double
        fopenArgs cell
    end
    
    properties (Access=private, Transient)
        ContentLength double
        % File identifier, if opened. Set to [] when closed or transfer is done. If
        % value is <0, don't close this file when done. This is the case where the
        % input argument was a file identifier, so we didn't open it.  If 0, treat it as
        % if -0.
        Fid double 
        % Original position indicator when input arg was a file identifier, set by
        % start(). This is -1 if we couldn't get the position. This is [] if input arg
        % was a file name.
        Fpos double 
        TextMode logical
    end
    
    methods
        function set.Filename(obj, value)
            if isempty(value)
                obj.RealFile = string.empty;
            else
                validateattributes(value, {'char' 'string'}, {'scalartext'}, mfilename, 'File');
                obj.setFile(value);
            end
        end
        
        function value = get.Filename(obj)
            value = obj.RealFile;
        end
        
        function obj = FileProvider(varargin)
        % FileProvider FileProvider constructor
        %  PROVIDERS = FileProvider(FILES) constructs an array of FileProviders, one for
        %    each file in the FILES array, each of which sends one file to the server.
        %    FILES is either a single filename specified as a string or character
        %    vector, or an array of filenames specified as a string array or cell array
        %    of character vectors. The filenames are interpreted as specified for
        %    fopen.
        %
        %    To terminate the file transfer before reaching the end of the file you can
        %    set FileSize to the number of bytes desired. To make the decision where to
        %    end the transfer based on the file contents while it is being read, write a
        %    subclass and override getData to examine the data being read and set the
        %    STOP return value to end the transfer.
        %
        %  PROVIDERS = FileProvider(FILES, PERMISSION, MACHINEFORMAT, ENCODING) specifies
        %    the PERMISSION, MACHINEFORMAT and ENCODING that should be used to open the
        %    files. The arguments are as documented for fopen, with trailing arguments
        %    optional. The only valid values of PERMISSION are 'r' or 'r+' with
        %    optional 't'. If 't' is used to indicate text mode, then on Windows, one
        %    carriage return preceding each line feed is removed.
        %
        %  PROVIDERS = FileProvider(FILEIDS) constructs an array of FileProviders, one
        %    for each open file identifier in double array FILEIDS. The files will be
        %    read starting at the current file position indicator to the end of the
        %    file, and the file identifiers will not be closed when transfer is
        %    complete. This method is useful if the file is already open, or when you
        %    want to transfer just the trailing part of the file: open the file, set the
        %    file position indicator to start of the data in the file that you want to
        %    transfer, and then pass that file identifier into this constructor. You
        %    may also set FileSize to limit the total number of bytes or write a
        %    subclass to control when to end the transfer.
        %
        % See also fopen, getData, FileSize, ContentProvider, MultipartProvider,
        % MultipartFormProvider
            import matlab.net.http.field.*, import matlab.net.http.*
            if nargin == 0
                return;
            end
            files = varargin{1};
            if isnumeric(files) && nargin > 1
                error(message('MATLAB:maxrhs'));
            end
            if ischar(files) || (~isempty(files) && ~isnumeric(files))
                files = matlab.net.internal.getStringVector(files, mfilename, 'FILES', false, {'double'});
            elseif isempty(files) 
                obj = obj.empty;
                return;
            end
            extraArgs = varargin(2:end);
            if ~isscalar(files)
                for i = numel(files) : -1 : 1
                    res(i) = copy(obj);
                    res(i).setFile(files(i), extraArgs{:});
                end
                obj = res;
            else
                % Now files is a single file name or identifier. 
                obj.setFile(files, extraArgs{:});
            end
        end
        
        function [data, stop] = getData(obj, length)
        % getData - return next buffer of data
        %   [DATA, STOP] = getData(PROVIDER, LENGTH) is an overridden method of
        %   ContentProvider that returns the next buffer of data from the file. It sets
        %   STOP to true if the end of file has been reached or FileSize bytes have been
        %   returned, whichever comes first.
        %
        % See also matlab.net.http.io.ContentProvider.getData
            if isempty(obj.Filename)
                data = [];
                stop = true;
                return;
            end
            if ~isempty(obj.FileSize)
                length = min([length, obj.FileSize - obj.BytesSent]);
            end
            if length > 0
                data = fread(abs(obj.Fid), length, '*uint8');
            end
            obj.BytesSent = obj.BytesSent + length;
            if isempty(data) || (~isempty(obj.FileSize) && obj.BytesSent == obj.FileSize)
                % empty must mean EOF or obj.FileSize reached 
                if obj.Fid > 0
                    % we opened the file, so close it
                    fclose(obj.Fid);
                    obj.Fid = [];
                end
                stop = true;
            else
                stop = false;
            end
        end
        
        function delete(obj)
            if ~isempty(obj.Fid) && obj.Fid > 0
                fclose(obj.Fid);
                obj.Fid = [];
            end
        end
        
        function str = string(obj)
        % STRING Show this object as a string
        %   STR = STRING(PROVIDER) returns information about this provider in a string.
        %   This is intended to be used for debugging. This information is also
        %   displayed by ContentProvider.show.
        %
        % See also show
            file = obj.Filename;
            if isempty(file) || strlength(file) == 0
                file = obj.RealFile;
                if isempty(file) 
                    file = "";
                end
            end
            str = obj.string@matlab.net.http.io.ContentProvider() + '(' + file + ')';
        end
    end
    
    methods (Access=protected)
        function complete(obj, ~)
        % COMPLETE completes the header for this message or part
        %   complete(PROVIDER, URI) is an overridden method of ContentProvider that adds
        %   Content-Disposition and/or Content-Type fields to the Header property. If
        %   these fields already exist in Header, even if their values are empty, they
        %   are not changed. However if a Content-Disposition field exists with a nonempty
        %   value, a filename parameter is added to the field naming the file specified
        %   in the File property. For example:
        %
        %     Content-Disposition: <previous content>; filename="foo.txt"
        %
        %   Subclasses must invoke this superclass method. Subclasses that do not want
        %   these fields to be added or altered should add these fields with empty values
        %   prior to calling this method.
        %
        % See also matlab.net.http.io.ContentProvider.complete, Header
            import matlab.net.http.field.*
            import matlab.net.http.*
            
            obj.complete@matlab.net.http.io.ContentProvider();
            if isempty(obj.Filename)
                return
            else
            end
            
            % Get existing Content-Disposition and Content-Type fields, if any.
            % If not create them.
            cdf = obj.Header.getValidField('Content-Disposition');
            ctf = obj.Header.getValidField('Content-Type');
            if ~isempty(ctf)
                mt = ctf.convert();
            else
                mt = MediaType.empty;
            end
            if isempty(cdf) || isempty(cdf.getParameter('filename')) || isempty(mt)
                % Add filename parameter to Content-Disposition field, if there isn't one
                if isempty(cdf) 
                    newcdf = ContentDispositionField;
                elseif ~isempty(cdf.Value) && isempty(cdf.getParameter('filename')) 
                    newcdf = cdf;
                else
                    newcdf = [];
                end
                [~,fname,fext] = fileparts(obj.Filename);
                % construct a header that contains a Content-Disposition field naming the file
                % and a Content-Type naming a type/subtype derived from the filename extension
                if isempty(mt) 
                    % There was no Content-Type field, or it was empty, so get the type
                    % from the extension
                    [~, ~, map] = matlab.net.http.internal.getTypeMaps;
                    if strlength(fext) ~= 0
                        try
                            typeSubtype = map(char(extractAfter(fext,1)));
                            mt = strjoin(typeSubtype, '/');
                        catch e
                            % the only error expected is NoKey to indicate that the filename extension is
                            % not in our map. In this case assume binary.
                            if ~contains(e.identifier, 'NoKey')
                                rethrow(e)
                            else
                            end
                        end
                    else
                    end
                    if isempty(mt)
                        mt = MediaType('application/octet-stream');
                    else
                    end
                    if isempty(ctf) || ~isempty(ctf.Value)
                        newctf = ContentTypeField(mt);
                        if isempty(ctf)
                            obj.Header = obj.Header.addFields(newctf);
                        else
                            obj.Header = obj.Header.changeFields(newctf);
                        end
                    else
                    end
                end
                if ~isempty(newcdf)
                    newcdf = newcdf.setParameter('filename', string(fname) + string(fext));
                    obj.Header = obj.Header.replaceFields(newcdf);
                else
                end
            end
        end
        
        function start(obj)
        % START Start a new transfer
        %   START(PROVIDER) is an overridden method of ContentProvider that MATLAB calls
        %   to prepare this provider for new transfer.
        % 
        % See also matlab.net.http.io.ContentProvider.start
            obj.start@matlab.net.http.io.ContentProvider();
            if isempty(obj.Filename)
                return
            else
            end
            obj.BytesSent = 0;
            if obj.Fid > 0
                % We opened the file previously. This must be a restart, so close the file to
                % start over.
                fclose(obj.Fid);
                obj.Fid = [];
            else
            end
            if isempty(obj.Fid)
                % File not opened, so open it using original pathname
                obj.Fid = fopen(obj.Filename, obj.fopenArgs{:});
                if obj.Fid < 0
                    % file is gone or no longer readable
                    obj.Fid = [];
                    error(message('MATLAB:http:FileNotFound', obj.Filename));
                else
                end
            else
                % File opened by user; file identifier was passed in
                assert(obj.Fid <= 0);
                if ~isempty(obj.Fpos)
                    % we already started the transfer; need to restart
                    if obj.Fpos >= 0
                        % try to seek to starting position
                        stat = obj.restoreFpos();
                    else
                    end
                    if obj.Fpos < 0 || stat < 0
                        % unable to seek to starting position
                        error(message('MATLAB:http:CannotRestartTransfer', obj.Filename));
                    else
                    end
                else
                    obj.saveFpos();
                end
            end
        end
        
        function length = expectedContentLength(obj, varargin)
        % expectedContentLength Return length of data
        %   LEN = expectedContentLength(PROVIDER, FORCE) is an overridden method of
        %   ContentProvider that returns the length of the data or [] if the length is
        %   unknown. 
        % 
        % See also matlab.net.http.io.ContentProvider.expectedContentLength
            force = ~isempty(varargin) && varargin{1};
            if force
                length = 0;
            else
                length = [];
            end
            if obj.TextMode
                % in text mode we can't predict the length of the file without reading it all,
                % so do that, but only if force specified
                if force
                    if obj.Fid <= 0
                        obj.saveFpos();
                        fid = -obj.Fid;
                    elseif isempty(obj.Fid)
                        fid = fopen(obj.Filename, obj.fopenArgs{:});
                    end
                    if fid > 0
                        [~, length] = fread(fid, intmax('uint64'));
                        if obj.Fid <= 0
                            stat = obj.restoreFpos();
                            if stat < 0
                                error(message('MATLAB:http:CannotRestartTransfer', obj.Filename));
                            else
                            end
                        else
                            fclose(fid);
                        end
                    end
                end
            else
                if isempty(obj.ContentLength)
                    fdata = dir(char(obj.Filename));
                    if ~isempty(fdata)
                        obj.ContentLength = fdata.bytes;
                        if obj.Fid < 0
                           obj.saveFpos();
                           if ~isempty(obj.Fpos) && obj.Fpos >= 0
                               obj.ContentLength = obj.ContentLength - obj.Fpos;
                           else
                               obj.ContentLength = [];
                           end
                        else
                        end
                    else
                    end 
                else
                end
                length = obj.ContentLength;
                if ~isempty(length) && ~isempty(obj.FileSize)
                    length = min([length obj.FileSize]);
                else
                end
            end
        end
        
        function tf = restartable(~)
        % RESTARTABLE Indicate provider is restartable
        %   TF = RESTARTABLE(PROVIDER) is an overridden method of ContentProvider that
        %   indicates whether this provider is restartable. Always returns true.
        %
        % See also matlab.net.http.io.ContentProvider.restartable, reusable
            tf = true;
        end
        
        function tf = reusable(~)
        % REUSABLE Indicate provider is reusable
        %   TF = REUSABLE(PROVIDER) is an overridden method of ContentProvider that
        %   indicates whether this provider is reusable. Always returns true.
        %
        % See also matlab.net.http.io.ContentProvider.reusable, restartable
            tf = true;
        end
    end
    
    methods (Access=private)
        function setFile(obj, file, varargin)
        % Set the file (identifier or name) in this object. varargin are extra fopen args
        % Make sure it's readable and store its absolute path in obj.Filename
            if isnumeric(file)
                [obj.RealFile, perm] = fopen(file);
                if strlength(obj.RealFile) == 0
                    error(message('MATLAB:http:BadFileIdentifier', file));
                end
                obj.Fid = -file; % note 0 stays 0
            else
                % pass in extra args to make sure they're valid for fopen
                fid = fopen(file, varargin{:}); 
                if fid < 0
                    error(message('MATLAB:http:FileNotFound', file));
                end
                clean = onCleanup(@()fclose(fid));
                % store full pathname of the file
                [obj.RealFile, perm] = fopen(fid);
            end
            % only these permissions support reading
            if ~any(contains(perm, ["r" "r+" "w+" "a+"]))
                fn = regexprep(obj.Filename, '"(.*)"','$1'); 
                if isnumeric(file)
                    % remove quotes around quoted name like "stdout" because message already quotes
                    % the name
                    error(message('MATLAB:http:FileIDNotReadable',file,fn));
                else
                    error(message('MATLAB:http:FileNotReadable',fn));
                end
            end
            obj.TextMode = endsWith(perm,'t') && ispc;
            obj.ContentLength = [];
            obj.fopenArgs = varargin;
        end
        
        function saveFpos(obj)
        % Save current file position 
            if isempty(obj.Fpos)
                % get starting file position; this may return -1, but that's OK providing we
                % never have to re-seek to here
                obj.Fpos = ftell(abs(obj.Fid));
            end
        end
        
        function stat = restoreFpos(obj)
        % Restore saved file position; returns -1 on error
            stat = fseek(abs(obj.Fid), obj.Fpos, -1);
        end
    end        
    
end


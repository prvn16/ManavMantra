classdef ImageConsumer < matlab.net.http.io.ContentConsumer
% ImageConsumer Consumer for image data in HTTP payloads
%   This consumer reads image data from the web converts it to MATLAB image
%   data, storing the result in the Body of the ResponseMessage to which it is
%   applied. Specified directly as a consumer in RequestMessage.send, it
%   provides the same functionality that would be provided by the default send
%   method when no consumer is specified, saving the converted image, plus a
%   possible colormap and alpha channel, in Body.Data, based on the Content-Type
%   of the message. See MessageBody.Data description for image/* types for more
%   information on conversion of image data in a response.
%
%   This consumer only accepts data for which it can determine a format based on
%   headers in the response message or the extension of the file name in the URI
%   of the request (if any). You can override this and specify the expected
%   format in the Format property.
%
%   This consumer is intended to return the data as a MATLAB image in one of the
%   formats described for the return value of imread. If you want to store the
%   original data in a file without converting it, use FileConsumer.
%
%   ImageConsumer methods:
%     ImageConsumer     - constructor
%  
%   ImageConsumer properties:
%     Info              - information about the image
%     PartialData       - unconverted data after error
%     Format            - Image format to use to process data
%
%   For subclass authors
%   --------------------
%   Create a subclass of ImageConsumer in order to process raw image data as it is
%   being received, by overriding putData and possibly other methods in
%   ContentConsumer.
%
%   ImageConsumer methods:
%     putData           - save next buffer of data
%     initialize        - initialize for new message
%
% See also matlab.net.http.ResponseMessage, matlab.net.http.RequestMessage,
% ContentConsumer, FileConsumer, imread, imformats, matlab.net.http.MessageBody

% Copyright 2017 The MathWorks, Inc.

    properties (SetAccess=private)
        % Info - a structure with information about the image
        %   The contents is as described for imfinfo. MATLAB sets this property only
        %   after a successful conversion. The Filename field in this structure is
        %   empty.
        %
        % See also imfinfo
        Info struct
        
        % PartialData - partial image data
        %   MATLAB sets this to the raw received data (uint8 vector) if conversion
        %   failed or transfer was interrupted. It may not contain any data during a
        %   transfer or in successful cases.
        PartialData uint16
    end
    
    properties
        % Format - image format
        %   This consumer will reject messages whose format is not one of those
        %   specified in the EXT column of imformats. Default value of this property is
        %   empty, which attempts to derive the format from the Content-Type field or
        %   the extension of the filename in the Content-Disposition field of the
        %   response or in the URI of the request. If you want to force this consumer to
        %   process the data using a specific format, set this property before applying
        %   this consumer to a RequestMessage.send and it will override any derived
        %   format.
        %
        %   You might need to set this property if the server does not properly
        %   indicate the format type in the response header.
        %
        % See also imformats, matlab.net.http.RequestMessage, matlab.net.URI
        Format   string  % image subtype
    end
    
    properties (Access=private)
        FileID    double % temp file descriptor we're reading and writing; empty if file not open
        Subtype   string % image subtype; derived from Format, Content-Type, URI or Content-Disposition filename extension
        Extension string % file name extension to use for temp file
        Args      cell   % arguments to imread besides the format
    end
    
    methods
        function set.Format(obj, format)
            if ~isempty(format) 
                if strlength(format) == 0
                    format = string.empty;
                elseif isempty(imformats(char(format)))
                    formats = imformats;
                    format = validatestring(format,[formats.ext],mfilename,'Format');
                end
            else
            end
            obj.Format = format;
        end
        
        function obj = ImageConsumer(varargin)
        % ImageConsumer Create consumer for HTTP images
        %   CONSUMER = ImageConsumer() constructs an ImageConsumer that processes the
        %   data as an image whose format is derived from headers in the response
        %   message or the file extension of the URI.
        %
        %   CONSUMER = ImageConsumer(FMT) constructs an ImageConsumer that uses the
        %   format specified by FMT. The FMT argument is a value acceptable to imread.
        %   FMT overrides any format specification in the message header. The value of
        %   FMT is saved in the Format property.
        %
        %   CONSUMER = ImageConsumer(___,ARG1,ARG2,...) passes along additional
        %   arguments to imread, other than the FILENAME and FMT arguments, used to
        %   convert the response data.
        % 
        % See also ImageConsumer, ContentConsumer, imread, Format
            obj = obj@matlab.net.http.io.ContentConsumer();
            if nargin > 0
                firstArg = varargin{1};
                obj.Args = varargin;
                if ischar(firstArg) || isstring(firstArg)
                    try
                        % if first arg is a string, try to parse as format; if that works, save rest of
                        % args
                        obj.Format = firstArg;
                        obj.Args = varargin(2:end);
                    catch
                    end
                else
                end
            else
            end
        end
        
        function [len, stop] = putData(obj, data)
        % putData Write image data
        %   [LEN, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that processes buffers of DATA, based on the ContentType
        %   property, and returns the result as MATLAB image data in Response.Body.Data.
        %   This method is only likely to be useful to subclasses of ImageConsumer.
        %
        %   After all the data in the message, the result is RGB data or a cell array
        %   containing image data, colormap and possible transparency, as documented for
        %   imread. For more information on image conversion, see the input conversion
        %   section of the help on the Data property of matlab.net.http.MessageBody.
        %
        %   This consumer does not guarantee that Response.Body.Data will have a useful
        %   result until the end of the data is reached (after putData is passed empty
        %   DATA). Subclasses that override this method, that want to examine the data
        %   stream while it is being received, should look at DATA, not
        %   Response.Body.Data. 
        %
        %   Subclasses that only want to see the result after conversion to MATLAB image
        %   data can examine Response.Body.Data after calling this method with empty
        %   DATA.
        %
        %   After the end of data, this method sets the Info property.
        %
        % See also ContentConsumer, ContentType, Info, imread, matlab.net.http.MessageBody
        
            % IMPLEMENTATION NOTE: Since we do not have a streaming image converter, this
            % implementation writes the data to a temp file and then at the end, reads it
            % back using imread. As a result, PartialData will be empty except after an
            % error. We create the temp file in start() and delete it on putData(empty),
            % any error, or when this consumer is deleted.
            stop = true;
            len = 0;
            if ~isempty(obj.FileID)
                % above test should really be an assert, but this method is public so it could
                % be called by anyone at the wrong time
                if isempty(data)
                    % end of data; close temp file and read it back as image; then delete the file
                    filename = fopen(obj.FileID);
                    fclose(obj.FileID);
                    obj.FileID = [];
                    import matlab.net.http.internal.*
                    clean = onCleanup(@()obj.closeAndDeleteTempFile(true, false, filename));
                    try
                        % This calls the same function to read the file as it would for
                        % any image/* Content-Type if no consumer had been specified.
                        % Note subtype has already been set by initialize to either Format (if
                        % specified) or the type derived from headers or the URI.
                        nouts = nargout(@imread);
                        if strlength(obj.Subtype) ~= 0
                            [res{1:nouts}] = imread(filename, char(obj.Subtype), obj.Args{:});
                        else
                            [res{1:nouts}] = imread(filename, obj.Args{:});
                        end
                        % remove trailing empty arguments
                        while length(res) > 1 && isempty(res{end})
                            res(end) = [];
                        end
                        if isscalar(res)
                            % if just one nonempty argument, unwrapped from cell
                            res = res{1};
                        end
                        obj.Response.Body.Data = res;
                    catch e
                        % Error converting image. Save it in PartialData and delete temp file
                        rethrow(e);
                    end
                    % success, get info about the image, report EOF to superclass, and delete the
                    % temp file
                    obj.Info = imfinfo(filename);
                    [len, stop] = obj.putData@matlab.net.http.io.ContentConsumer(uint8.empty);
                else
                    % add more data to the file
                    e = [];
                    try
                        len = fwrite(obj.FileID, data);
                        stop = len < length(data); % expect all bytes to be written
                    catch e 
                        % stop = true if we come here
                    end
                    if (stop)
                        % premature end; couldn't write all bytes to temp file
                        % could be someone deleted file or file system was full
                        % save partial data and close and delete temp file
                        filename = obj.closeAndDeleteTempFile(true, false);
                        if isempty(e)
                            error(message('MATLAB:http:ErrorWritingToTempFile', filename));
                        else
                            rethrow(e);
                        end
                    else
                    end
                end
            end
        end
    end
    
    methods (Access=protected)
        function ok = initialize(obj)
        % initialize Initialize consumer for a new message
        %   OK = initialize(CONSUMER) is an overridden method of ContentConsumer that
        %   initializes this consumer for receipt of a new image. Returns false if
        %   the Content-Type header is present and its Type is not 'image', or if the
        %   Format property is empty and the subtype is not one of those that imread
        %   accepts as a file extension. 
        %
        % See also matlab.net.http.io.ContentConsumer.initialize, ContentType, imread
            ok = isempty(obj.ContentType) || strcmpi(obj.ContentType.Type, 'image');
            if (ok)
                oldSubtype = obj.Subtype;
                % Try to determine the temporary filename extension, which imread will use to
                % determine how to parse the file. 
                [subtype, obj.Extension] = obj.getFileExtension();
                obj.Subtype = subtype;
                if ~isempty(obj.FileID) && ~strcmp(obj.Subtype, oldSubtype)
                    % subtype changed and we had a temp file; delete it
                    delete(fopen(obj.FileID));
                    obj.FileID = [];
                else
                end
                if ~isempty(obj.Extension) && strlength(obj.Extension) ~= 0
                    ok = ~isempty(imformats(char(extractAfter(obj.Extension,1))));
                elseif ~isempty(subtype)
                    ok = ~isempty(imformats(char(subtype)));
                else
                end
            else
            end
            obj.FileID = [];
            obj.PartialData = [];
        end
        
        function len = start(obj)
        % START start receipt of an image
        %   BUFSIZE = START(CONSUMER) is an abstract method of ContentConsumer that MATLAB
        %   calls to indicate that receipt of data is about to start.
        %
        % See also matlab.net.http.io.ContentConsumer.start
            
            % Creates a temporary file for writing the image data. The file is deleted when
            % this object is destroyed or all the data in the message has been successfully
            % read. If this method is called a second time while the file is still open,
            % and the subtype has not changed, the file is reused. This is unlikely, since
            % MATLAB doesn't call this method more than once per message, but a sublcass
            % might be reusing us.
            len = [];
            if isempty(obj.FileID)
                % Create new temp file. The extension may be empty, in which case
                % we have to hope that imread can still read it based on subtype.
                filename = string(tempname) + obj.Extension;
            else
                % reuse temp file by closing and reopening
                filename = fopen(obj.FileID);
                fclose(obj.FileID);
                obj.FileID = [];
            end
            obj.FileID = fopen(filename, 'w+');
            obj.PartialData = [];
        end
    end
    
    methods (Access=private)
        function filename = closeAndDeleteTempFile(obj, returnData, fromDelete, filename)
        % Close the temp file, optionally return its data in obj.PartialData and delete
        % it
        %   returnData           save contents in obj.PartialData
        %   fromDelete           from delete method; don't throw error
        %   filename (optional)  name of the file; else use obj.FileID
            if nargin > 3
                fid = fopen(filename);
            else
                filename = [];
                fid = obj.FileID;
            end
            if ~isempty(fid)
                if returnData
                    if isempty(filename)
                        % file already open; seek to beginning
                        fseek(fid,0,-1); 
                    else
                    end
                    if fid > 0
                        obj.PartialData = fread(fid,'*uint8');
                    else
                        obj.PartialData = [];
                    end
                end
                if isempty(filename)
                    filename = fopen(fid);
                else
                end
                fclose(fid);
                obj.FileID = [];
                if ~isempty(filename)
                    [lastmsg,lastid] = lastwarn('');
                    clean = onCleanup(@()lastwarn(lastmsg,lastid));
                    delete(filename);
                    if ~fromDelete && ~isempty(lastwarn)
                        % Can't delete: this must be a bug, so OK not to translate.
                        error('Internal error "%s" deleting temporary file "%s"\n', lastwarn, filename);
                    end
                    clear clean
                else
                end
            else
                filename = '';
            end
        end

        function delete(obj)
        % Delete temp file when this object is deleted.
            obj.closeAndDeleteTempFile(false, true);
        end
        
        function [subtype, extension] = getFileExtension(obj)
        % Returns subtype (char vector) and file extension (string including ".") based
        % on the Content-Type, Content-Disposition, or filename in the URI. Both may be
        % empty strings. But if Format is set, just uses that as the subtype.
            if ~isempty(obj.Format)
                subtype = char(obj.Format);
                extension = "." + subtype;
            else
                if ~isempty(obj.ContentType)
                    % if we have a Content-Type field, use subtype as extension
                    subtype = obj.ContentType.Subtype;
                    extension = '.' + subtype;
                else
                    % If no Content-Type field, get it from the filename in the Content-Disposition
                    % field, if any, or the filename at the tail end of the URI's Path, if any.
                    cdf = obj.Header.getValidField('Content-Disposition');
                    filename = [];
                    if ~isempty(cdf)
                        filename = cdf.getParameter('filename');
                    else
                    end
                    if isempty(filename) || strlength(filename) == 0
                        filename = obj.URI.Path(end);
                    else
                    end
                    if ~isempty(filename) && strlength(filename) ~= 0
                        [~, ~, extension] = fileparts(filename);
                        if isempty(extension) || strlength(extension) == 0
                            subtype = '';
                        else
                            subtype = char(extractAfter(extension,1));
                        end
                    else
                        % if tail of filename is empty, there's either no filename or the URI ended in
                        % '/'.
                        extension = "";
                        subtype = '';
                    end
                end
            end
        end
        
    end
end


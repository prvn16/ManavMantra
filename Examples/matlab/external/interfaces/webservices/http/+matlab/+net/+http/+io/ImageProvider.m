classdef ImageProvider < matlab.net.http.io.ContentProvider
% ImageProvider ContentProvider that sends MATLAB image data
%   This is a ContentProvider that converts and sends MATLAB image data in an
%   HTTP RequestMessage. It converts the data to one of the standard types, as
%   specified by the Content-Type of the request or properties in this object.
%   This provider also converts an image file to a different format.
%
%   By default, if you specify an image Content-Type in the RequestMessage
%   (e.g., image/jpeg) and RequestMessage.Body is a MessageBody containing your
%   image data, MATLAB will assume that MessageBody.Data is image data and will
%   try to convert it appropriately. By using an ImageProvider in
%   RequestMessage.Body, you may have more control over how your data is
%   converted.
%
%   If the RequestMessage contains no Content-Type header field, this provider
%   adds the appropriate image Content-Type to the header. Otherwise the header
%   field will be left alone and conversion will be done as specified in
%   properties of this object even if its value is inconsistent with the
%   Content-Type field.
%
%   ImageProvider properties:
%     Data          - the MATLAB data to be converted
%     Arguments     - cell array of arguments to imwrite
%     Filename      - the filename containing the image data, if from file
%
%   ImageProvider methods:
%     ImageProvider - constructor
%
%   For subclass authors
%   --------------------
%
%   ImageProvider methods (overridden from ContentProvider):
%     complete      - complete message header
%     start         - start transfer of image
%     restartable   - return to indicate provider is restartable
%     reusable      - return to indicate provider is reusable
%
% See also ContentProvider, FileProvider, matlab.net.http.RequestMessage, 
% matlab.net.http.MessageBody, imwrite


% Copyright 2017 The MathWorks, Inc.
    properties
        % Data - the MATLAB data to be converted
        %   This is the value specified as the DATA argument to the constructor, if any,
        %   or the data converted from the FILENAME. You may set this value to a string
        %   scalar or character vector at any time prior to sending the message
        %   containing this provider.
        %
        %   Subclass authors may set this prior to MATLAB's call to START (e.g., in
        %   COMPLETE). If you change this, it won't take effect until the next call to
        %   START.
        %
        % See also ImageProvider.ImageProvider, start, complete, Filename
        Data 
    end
    
    properties (SetAccess=private)
        % Filename - the filename containing the image data
        %   This is the value specified as the FILENAME argument to the constructor, if
        %   any. It is read-only.
        %
        % See also ImageProvider.ImageProvider, Data
        Filename string
    end
    
    properties (Dependent)
        % Arguments - cell array of arguments to imwrite
        %   This is the value specified to the constructor containing a list of
        %   arguments as documented for imwrite, but omitting the image data and
        %   filename arguments.
        %
        %   Subclass authors may set this prior to MATLAB's call to START (e.g., in
        %   COMPLETE). If you change this, it won't take effect until the next call to
        %   START.
        %
        % See also ImageProvider.ImageProvider, imwrite, start, complete
        Arguments cell % dependent because set.Arguments accesses other properties
    end
    
    properties (Access=private, Transient)
        MediaType matlab.net.http.MediaType
        FormatInArguments logical = false
        TempFilename char
        URI matlab.net.URI
        RealArguments cell
    end
    
    properties (Access=private, Constant)
        DefaultMediaType = matlab.net.http.MediaType('image/jpeg')
    end
    
    methods
        function obj = ImageProvider(data, varargin)
        % ImageProvider ContentProvider that sends image data
        %   PROVIDER = ImageProvider(DATA, ARGS, ...) creates a provider that converts
        %   MATLAB image data DATA to the format specified by ARGS. ARGS is an optional
        %   list of arguments as documented for IMWRITE, except that the image data A
        %   and the FILENAME are omitted. If ARGS contains a FMT argument specifying
        %   the format, the image will be converted to that format, and the Content-Type
        %   field of the message, if not otherwise specified, will be set to that
        %   format. If there is no FMT argument, the format of the image will be taken
        %   from the Content-Type field of the message. If there is no such field or
        %   its value is empty, the Content-Type will be "image/jpeg".
        %
        %   PROVIDER = ImageProvider(FILENAME, ARGS, ...) obtains the image data from
        %   the file FILENAME and sends it in the format specified in ARGS or the
        %   Content-Type field, as described above. In this case the format of FILENAME
        %   is derived from the filename extension, which may be different from the FMT
        %   argument in ARGS or the Content-Type in the message. This form of
        %   constructor allows you to send an image file in one format to a server that
        %   expects it in a different format.  However, some conversions are
        %   incompatible, e.g. converting an RGB file like JPEG to GIF.
        %
        %   While this provider will convert a file in one format to data in another
        %   format, it is not designed to send an image file as is. To send a file
        %   without changing its format, it is better to use FileProvider.
        %
        %   Note that, if you do not specify a FMT argument in ARGS or a Content-Type
        %   header field, the default output format is JPEG, so the image data will be
        %   converted to JPEG regardless of the file format.  
        %
        % See also imwrite, imread, FileProvider, Data, Filename, Arguments
            if nargin > 0
                if ischar(data) || isstring(data)
                    validateattributes(data, {'string','char'}, {'scalartext'}, mfilename, 'FILENAME');
                    obj.Filename = data;
                    data = imread(char(obj.Filename));
                end
                obj.Data = data;
                obj.Arguments = varargin;
            end
        end
        
        function set.Arguments(obj, value)
            % Normally just save the arguments, but if the MediaType is not set, try to set
            % it based on the format specified in the arguments.
            % If any arguments are strings, make them chars, because that's what imwrite
            % wants.
            % Any change to the arguments deletes any temp file we might have created from
            % previous arguments
            function arg = convertToChar(arg)
                if isstring(arg)
                    arg = char(arg);
                else
                end
            end
            obj.RealArguments = cellfun(@convertToChar, value, 'UniformOutput', false);
            obj.FormatInArguments = false;
            obj.CurrentDelegate = matlab.net.http.io.ContentProvider.empty;
            obj.deleteTempFile();
            obj.MediaType = matlab.net.http.MediaType.empty;
            % Expect the first argument that is a string to be a format; if not, don't set
            % the MediaType
            for i = 1 : length(value)
                arg = value{i};
                if ischar(arg) || isstring(arg)
                    format = imformats(char(arg));
                    if ~isempty(format)
                        obj.FormatInArguments = true;
                        mtMap = matlab.net.http.internal.getTypeMaps();
                        if isKey(mtMap, format.ext)
                            type = mtMap(format.ext{1});
                            if ~isempty(type)
                                obj.MediaType = matlab.net.http.MediaType([type{1} '/' type{2}]); 
                            end
                        end
                    end
                    break;
                end
            end
        end
        
        function value = get.Arguments(obj)
            value = obj.RealArguments;
        end
        
        function set.Data(obj, value)
            obj.deleteTempFile();
            obj.Data = value;
        end
        
        function [data, stop] = getData(obj, length)
            assert(~isempty(obj.CurrentDelegate))
            [data, stop] = obj.CurrentDelegate.getData(length);
            if stop
                obj.deleteTempFile();
            end
        end
    end
    
    methods (Access=protected)
        function complete(obj, uri)
        % complete Complete the header of the message
        %   complete(PROVIDER, URI) is an overridden method of ContentProvider that
        %   completes the header of the message, or (in the case of a multipart message)
        %   the part for which this provider is being used. If there is no Content-Type
        %   field, it adds one specifying the MediaType derived from the arguments to
        %   the constructor. If there is one, it sets the MediaType. If it can't be
        %   determined from either the Content-Type or the arguments, try to derive it
        %   from the suffix of the filename in the Content-Disposition field. If that
        %   doesn't work, use image/jpeg.
        %
        % See also matlab.net.http.io.ContentProvider.complete, matlab.net.http.MediaType
            
            obj.complete@matlab.net.http.io.ContentProvider(uri);
            ctf = obj.Header.getValidField('Content-Type');
            % If we have a MediaType, it was previously determined or derived it from the
            % arguments to the constructor, so don't change it.
            if isempty(obj.MediaType)
                % If we have no MediaType, this means there was no format argument to the
                % constructor, so try to derive the MediaType
                if ~isempty(ctf)
                    % There was a Content-Type field, so we won't change or add one.
                    % Get MediaType from Content-Type field. If its value is empty, it means we
                    % should suppress it.
                    obj.MediaType = ctf.convert();
                else
                    % No Content-Type field; look for Content-Disposition field and check the
                    % extension of the filename parameter
                    cdf = obj.Header.getValidField('Content-Disposition');
                    if ~isempty(cdf)
                        fn = cdf(1).getParameter('filename');
                        if ~isempty(fn)
                            [~,~,ext] = fileparts(fn);
                            if ~isempty(ext)
                                % filename has extension; remove the '.' and look it up in the type maps to
                                % obtain a MediaType
                                ext = char(ext);
                                ext(1) = [];
                                [~,~,typeMap] = matlab.net.http.internal.getTypeMaps();
                                if typeMap.isKey(ext)
                                    type = typeMap(ext);
                                    obj.MediaType = matlab.net.http.MediaType([type{1} '/' type{2}]);
                                end
                            end
                        end
                    end
                end
              
                if isempty(obj.MediaType)
                    obj.MediaType = obj.DefaultMediaType;
                end
            end
            % When we get here obj.MediaType is equal to the value specified in arguments to
            % the constructor, or if not specified there, the ContentTypeField or suffix of
            % the filename in the ContentDispositionField in Header. If all those were
            % empty, it's image/jpeg.
            if isempty(ctf)
                % if there is no Content-Type field at all, add one
                obj.Header = obj.Header.addFields(matlab.net.http.field.ContentTypeField(obj.MediaType));
            end
            obj.URI = uri;
        end
        
        function start(obj)
        % START Start a new transfer
        %   START(PROVIDER) is an overridden method of ContentProvider that MATLAB calls
        %   to prepare this provider for new transfer.
        % 
        % See also matlab.net.http.io.ContentProvider.start
            start@matlab.net.http.io.ContentProvider(obj);
            obj.createTempFile();
            if isempty(obj.CurrentDelegate)
                % success converting data; save the filename for cleanup, and delegate transfer
                % to a new FileProvider.
                try
                    % Delegate transmission of the data to FileProvider, which reads our temp file.
                    % FileProvider will set header fields in its Header property, but we ignore
                    % them. It's too late, in this start method, to alter any header fields because
                    % the header was already sent to the server.
                    fileProvider = matlab.net.http.io.FileProvider(obj.TempFilename);
                    obj.delegateTo(fileProvider, obj.URI);
                catch e
                    obj.deleteTempFile();
                    rethrow(e);
                end
            else
                % We already have a FileProvider, just restart it.  Happens if previous transfer
                % was aborted and we were not properly cleaned up.
                assert(~isempty(obj.CurrentDelegate));
                obj.CurrentDelegate.start();
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
        
        function len = expectedContentLength(obj, varargin)
            if ~isempty(varargin) && varargin{1}
                % force specified, so write data to temp file if we haven't done it yet
                obj.createTempFile();
                if ~isempty(obj.TempFilename)
                    d = dir(obj.TempFilename);
                    len = d.bytes;
                else
                    len = 0;
                end
            else
                len = [];
            end
            
        end
    end
    
    methods (Access=private)
        function createTempFile(obj)
        % If obj.TempFilename is empty, write Data to a temp file using imwrite, and
        % save name of file in obj.TempFilename.  If Data is empty, obj.TempFilename 
        % remains empty.
            if isempty(obj.TempFilename) && ~isempty(obj.Data)
                % if we have no temp file yet, create one
                tempFilename = tempname;
                % Decide where in the argument list to imwrite to put the filename. It's either
                % the 1st or 2nd argument after the image data.
                fnPos = 1;
                if ~isempty(obj.Arguments) 
                    if ~ischar(obj.Arguments{1}) && ~isstring(obj.Arguments{1})
                        % if first arg is not a string, assume it's a colormap, filename goes in
                        % position 2
                        fnPos = 2;
                    end
                    args = {obj.Arguments{1:fnPos-1} tempFilename obj.Arguments{fnPos:end}};
                else
                    args = {tempFilename};
                end 
                if ~obj.FormatInArguments
                    if isempty(obj.MediaType)
                        obj.MediaType = obj.DefaultMediaType;
                    end
                    % add the subtype as the format argument if there wasn't one
                    args = {args{1:fnPos} char(obj.MediaType.Subtype) args{fnPos+1:end}};
                end
                % Write image data to the temp file. 
                try
                    imwrite(obj.Data, args{:});
                catch e
                    % imwrite doesn't always clean up the temp file on an error
                    if exist(tempFilename,'file') > 0
                        delete(tempFilename);
                    end
                    rethrow(e)
                end
                assert(exist(tempFilename,'file') > 0, "Internal error: imwrite failed to create temp file %s\n", tempFilename);
                % If no error, assume tempFilename is good
                obj.TempFilename = tempFilename;
            end
        end
        
        function delete(obj)
            obj.deleteTempFile();
        end
        
        function deleteTempFile(obj)
            if ~isempty(obj.TempFilename)
                fn = obj.TempFilename;
                obj.TempFilename = char.empty;
                obj.CurrentDelegate = matlab.net.http.io.ContentProvider.empty;
                delete(fn);
            end
        end
    end        
       
    
end


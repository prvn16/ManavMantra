function [data, payloadLength, payload, charset] = readContentFromWebService(arg1, arg2, convert, raw)
%readContentFromWebService Read content from Web service
%   [data, payloadLength, payload] = readContentFromWebService(connector, log,
%   convert, raw) reads the content from the Web service indicated by
%   connector and returns the response in data and payload, and the original
%   payloadLength.  If connector.Consumer is empty and convert is set, the
%   response is decoded based on connector.ContentType and returned in data.
%   If there is no ContentType, process as application/octet-stream (as per
%   section 3.1.1.5 of RFC 7231), which returns a uint8 vector.  Caller can do
%   "content sniffing" if this is needed.
%
%   If connector.Consumer is set, the consumer gets the payload, and if
%   Consumer.Response.Body is a MessageBody, return Consumer.Reponse.Body.Data
%   in data; otherwise data is [].  The consumer is responsible for any decoding.
%
%   data = readContentFromWebService(payload, contentType, convert) is the same, but reads and
%   converts the payload already in memory using the specified contentType or
%   application/octet-stream as above.  This form is used to re-convert a
%   payload received from the web that was improperly converted or which was
%   not converted the first time.  No consumer is involved here.
%
%   connector - a HTTPConnector object on which a request has been sent and
%               response received.  Returns empty if the connector has no response
%               message or the response has no content.  We use connector.ContentType
%               to determine the contentType for conversion.
%
%   log       - call connector.log to log the message containing this data
%
%   convert   - Used only if raw is false: If true, convert the payload to MATLAB 
%               data based on contentType and return in data.  If false, just
%               convert payload to Unicode based on charset in or implied by the
%               contentType.  If false and there is no charset, return raw
%               uint8 vector in data (same as payload).
%
%   raw       - (optional) If true, just return raw payload and leave data [].  In
%               this case payload must be specified.
%
%   contentType - the MediaType to use to convert the data or []
%
%   data      - the data, converted based on connector.Content-Type and charset and
%               whether convert is specified.
%
%   payloadLength - the length of the unconverted payload; useful when payload is not
%               being returned.
%
%   payload   - the unconverted data as a uint8 array.
%
%   charset   - If convert = false or raw = true, and contentType is character
%               data that we are returning in data, this is the charset we
%               used to convert the payload.  The purpose of this is to
%               communicate the charset when we didn't do a full conversion of
%               payload based on contentType, but only converted the
%               characters to Unicode.

% Copyright 2015-2017 The MathWorks, Inc.

    if nargin < 4
        raw = false;
    end
    useConnector = isa(arg1, 'matlab.net.http.internal.HTTPConnector');
    if useConnector
        connector = arg1;
        log = arg2;
        contentType = lower(connector.ContentType);
        if isempty(contentType)
            mediaType = [];
        else
            try
                mediaType = matlab.net.http.MediaType(contentType);
            catch
                % above throws if not resembling "type/subtype", so add "/*" to it
                mediaType = matlab.net.http.MediaType(string(contentType) + "/*");
            end
        end
        consumer = connector.getConsumer();
    else
        payload = arg1;
        mediaType = arg2;
        log = false;
        consumer = [];
    end
    if ~raw
        if isempty(consumer)
            % Convert the ContentType in the received message (e.g. text/plain,
            % application/json, etc) to a simple form (e.g. text, image, json, etc.)
            if isempty(mediaType)
                simpleType = [];
                charset = '';
            else
                simpleType = matlab.net.http.internal.getSimpleType(mediaType);
                subtype = lower(mediaType.Subtype);
                % this may return '' if no charset can be determined
                charset = matlab.net.internal.getCharsetForMediaType(mediaType);
            end
        else
            % If a consumer is specified, let the consumer decide what to do with the
            % type.
            simpleType = [];
        end
    else
        % expect payload if raw specified
        assert(nargout > 1)
    end    
    if ~raw && (~useConnector || convert) && ~isempty(simpleType) && isempty(consumer)
        % If no consumer and we're converting the data, determine if the mediaType
        % requires file download prior to conversion
        downloadToFile = contentRequiresFileDownload(simpleType);
        if downloadToFile
            filename = getTempname(simpleType, subtype);
            if isempty(filename)
                % empty filename means we can't convert it, so just return raw data
                downloadToFile = false;
                convert = false;
            end
        end
    else
        % If raw is set or a consumer was specified, don't write data to file
        downloadToFile = false;
    end
    
    if downloadToFile
        % We take this path only when convert = true and we need to write it to a
        % file in order to convert it.  Don't come here if a consumer was specified.
        cleanup = onCleanup(@()deleteFile(filename));
        if useConnector
            % This downloads the data from the server into the file
            connector.copyContentToFile(filename);
        else
            % payload was set above in the ~useConnector case
            f = fopen(filename, 'w');
            cleanf = onCleanup(@()fclose(f));
            fwrite(f, payload);
            payloadLength = length(payload);
            clear cleanf
        end
        e = [];
        try
            % Read it back, possibly using charset for simpleType = 'text', using the
            % converter based on simpleType and charset.  This function assumes we
            % don't call it for simpleTypes like 'json' that don't require file
            % download.
            data = matlab.net.http.internal.readContentFromFile(filename, ...
                                                     charset, simpleType, subtype);
            if exist('payload','var')
                payloadLength = length(payload);
            else
                % If we were called with a 1st argument of HTTPConnector, the payload was
                % written directly to the file, not passed in, so get its length.
                info = dir(filename);
                payloadLength = info.bytes;
            end
        catch e
            % just save the exception; it's some non-HTTP exception
        end
        if (~isempty(e) || nargout > 1 || log) && exist(filename,'file')
            % if there was an exception, or we need to get the payload for logging,
            % and the file was created, then fetch the payload from the file.
            f = fopen(filename,'r','n');
            clean2 = onCleanup(@()fclose(f));
            payload = fread(f,Inf','uint8=>uint8');
            payloadLength = length(payload);
            clear clean2
        end
        if ~isempty(e) 
            % If an exception occurred reading or converting content, throw
            % MATLAB:http exception with a special message that includes the message
            % in the exception.
            if useConnector
                me = MException(message('MATLAB:http:CannotConvertContent', ...
                                        char(connector.URI), char(mediaType)));
            else
                me = MException(message('MATLAB:http:CannotConvertPayload', ...
                                        char(mediaType)));
            end
            % Add e as the cause just so we can get its stack trace.
            % Adding e as the cause here will cause the message to be duplicated when
            % getReport is called on me, but this is the only way to get the original
            % stack to appear, since we can't directly set me.stack.
            me = me.addCause(e);
            % Throw an HTTPException that contains a history and a ResponseMessage with
            % the payload filled in.
            if isempty(charset)
                throw(matlab.net.http.internal.ExceptionWithPayload(payload, me));
            else
                % If there is a charset, then also populate data with the characters.  This gives
                % us human-readable input in ResponseMessage.Body.Data.
                data = string(native2unicode(payload', charset));
                throw(matlab.net.http.internal.ExceptionWithPayload(payload, me, data, charset));
            end
        end
        % conversion successful, no charset in this case
        charset = [];
    else
        % convert is false or content can be decoded without file download, or a
        % consumer was specified.
        % Read the raw data stream from the connection into a byteArray.  If a consumer
        % was specified, this actually makes calls out to the consumer for each buffer
        % of data read, and it is up to the consumer to populate any Body.Data in the
        % ResponseMessage.
        if useConnector
            payload = connector.copyContentToByteArray();
            url = char(connector.URI);
        else
            url = [];
        end
        if isempty(consumer)
            payloadLength = length(payload);
            if raw || isempty(payload)
                data = [];
                charset = [];
            else
                % Decode the byte array. Here, simpleType and charset may be empty.
                % This throws ExceptionWithPayload if decoding or conversion failed.
                data = matlab.net.http.internal.decodeByteArray(payload, charset, ...
                                                               simpleType, url, convert);
                if convert || isempty(simpleType)
                    % if data was converted or there was no simpleType (indicating we're just
                    % returning the binary data), don't return a charset.
                    charset = [];
                end
            end
        else
            % if a consumer was used, get any data it produced.  The consumer has the
            % option of storing nothing here.
            payloadLength = consumer.PayloadLength;
            if isa(consumer.Response.Body, 'matlab.net.http.MessageBody')
                data = consumer.Response.Body.Data;
            else
                data = [];
            end
            charset = [];
        end
    end
    
    if log
        connector.log(data, payload);
    end
end


%--------------------------------------------------------------------------

function fname = getTempname(simpleType, subtype)
% Return a temp file name for downloading content.  subtype must be string
    fname = tempname;
    suffix = matlab.net.http.internal.getSuffixForSubtype(simpleType, subtype);
    if isempty(suffix)
        if ~ischar(suffix)
            % suffix of [] indicates we recognize the simpleType but don't know how to
            % convert the subtype
            fname = [];
        end
    else
        fname = [fname '.' suffix];        
    end
end

%--------------------------------------------------------------------------

function downloadToFile = contentRequiresFileDownload(simpleType)
    % Return true if content requires downloading to a file.

    downloadToFile = any(strcmpi(simpleType,{'image','table','xmldom','audio'}));
end

%--------------------------------------------------------------------------

function deleteFile(filename)
    % Delete filename, if it exists.

    if exist(filename, 'file')
        delete(filename)
    end
end

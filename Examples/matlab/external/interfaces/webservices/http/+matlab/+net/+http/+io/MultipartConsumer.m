classdef MultipartConsumer < matlab.net.http.io.GenericConsumer
% MultipartConsumer Helper for multipart content types in HTTP messages
%   This consumer processes multipart HTTP response messages. A multipart message is
%   one whose Content-Type header field specifies "multipart", and whose body
%   contains one or more parts. Each part contains its own set of header
%   fields describing the part, the most important of which is a Content-Type
%   field.
%
%   Use this consumer when your server sends multipart messages. To use this
%   consumer, specify it in the call to RequestMessage.send, and give it pairs
%   of parameters that tell it what to do with message parts of possible
%   Content-Types: an array of types and a ContentConsumer to process those
%   types. If you do not specify what to do with a type, this consumer converts
%   the message part in a default manner and stores the results in the response.
%   For example,
%
%     r = matlab.net.http.RequestMessage();
%     ic = matlab.net.http.io.ImageConsumer('background',color);
%     fc = matlab.net.http.io.FileConsumer('Newfile.txt','u');
%     mc = matlab.net.http.io.MultipartConsumer(["image/gif" "image/jpeg"], ic, ...
%                                              'text/*', fc)
%     resp = r.send(url, [], mc);
%
%   will use an ImageConsumer for parts that contain JPEG or GIF images, and a
%   FileConsumer to create files named Newfile.txt, Newfile-1.txt, etc. for
%   parts that contain text data. In the returned ResponseMessage, for all
%   multipart subtypes except multipart/x-mixed-replace, resp.Body.Data contains
%   an array of ResponseMessages, one for each part in the message, in the order
%   the parts appeared in the response. Each ResponseMessage in the array
%   contains headers for the part and a body with any data that the consumer
%   stored for the part. For multipart/x-mixed-replace, there is only a single
%   ResponseMessage in the array containing the last part received, since this
%   subtype indicates that each part replaces the previous one.
%
%   In the above example, assume the response message is multipart/mixed and
%   contains 3 parts with these types, in this order:
%            text/html, image/jpeg, application/json. 
%   Then resp.Body.Data contains an array of 3 ResponseMessages, each with a
%   Header, Body and Body.Data:
%
%     resp.Body.Data(1).Body.Data   is empty because the text/html part was
%                                   processed by FileConsumer which stored the
%                                   data in Newfile.txt instead of saving it.
%     resp.Body.Data(2).Body.Data   contains MATLAB image data converted from
%                                   the image/jpeg part, because ImageConsumer
%                                   stores its data in the response. This
%                                   happens to be the same as MATLAB's default
%                                   processing for images, had no ImageConsumer
%                                   been specified.
%     resp.Body.Data(3).Body.Data   contains MATLAB data converted from a JSON
%                                   string in the part. This is MATLAB's
%                                   default processing for application/json because
%                                   the type was not mentioned in the
%                                   constructor.
%
%   For subclass authors
%   --------------------
%
%   If you are writing your own ContentConsumer, it will generally work whether
%   it is a top level consumer (i.e., specified as the 3rd argument to the
%   RequestMessage.send method) or a part of a multipart message (when specified
%   as a "delegate" in the MultipartConsumer constructor call).
%   MultipartConsumer makes it appear to each delegate as if it was handling the
%   entire response message, while actually assembling the results into an array
%   of ResponseMessages stored in the returned response.Body.Data.
%
%   The following describes MultipartConsumer's behavior:
%
%   Each time this MultipartConsumer receives a complete part of a message from
%   the server, it parses any headers in the part and then invokes the
%   appropriate delegate consumer appropriate for the Content-Type field in the
%   part. If there is no Content-Type field in the part, it assumes the type is
%   text/plain. If there is no delegate able to handle the type, it uses
%   default processing for the part based on the Content-Type, as described for
%   GenericConsumer.
%
%   MultipartConsumer does not invoke a delegate until it receives a complete
%   part. MultipartConsumer buffers the data for a part, and at the end of
%   receipt of the part, it copies all the visible properties of ContentConsumer
%   from this consumer to the delegate, clears the delegate's Response.Body,
%   sets the delegate's Header to the header of the part, and then calls the
%   delegate's initialize and start methods, followed by one or more calls to
%   the delegate's putData method containing the payload of the part, followed
%   by a call to putData(uint8.empty) to indicate end-of-data. If the delegate's
%   initialize method returns false to indicate it does not want to handle the
%   part, the payload of the part is processed using default behavior for the
%   Content-Type of the part, as described for GenericConsumer.
%
%   If the delegate's start method returns [] to indicate that there is no
%   maximum desired buffer size, MultipartConsumer makes just one call to
%   putData that provides the entire payload of the part, followed by the
%   end-of-data call. Otherwise it will call putData enough times to supply the
%   entire payload in units of the buffer size.
%
%   If the delegate's putData method sets the STOP return value to true to
%   indicate that it does not want any more data, MultipartConsumer gracefully
%   closes the connection to end the transfer, as if the message had ended. In
%   this way the delegate can control whether the remainder of the original
%   message should be processed. If putData returns a SIZE of [], the message
%   also ends, but with an exception thrown to the caller of
%   RequestMessage.send.
%
%   If the consumer for a part was specified as a function handle rather than a
%   ContentConsumer instance, the function is called only the first time the
%   consumer is needed, and subsequently the same consumer instance is used for
%   any appropriate parts of the same response message. For parts processed by
%   a function handle, the corresponding ResponseMessage in Response.Body.Data
%   contains only a header for the part, because the function does not have
%   access to the ResponseMessage body.
%
%   A delegated consumer may access this consumer and its properties through its
%   MyDelegator property, though that is rarely necessary.
%
%   MultipartConsumer methods:
%     MultipartConsumer      - Constructor
%
%   MultipartConsumer methods (overridden from superclass, called by MATLAB or subclasses)
%     initialize             - Prepare for new message
%     start                  - Start receiving new message
%     putData                - Store next buffer of data
%
%   MultipartConsumer properties (read-only)
%     Preamble           - payload prior to first multipart boundary delimiter
%     Epilogue           - payload following last multipart boundary delimiter
%
% See also GenericConsumer, matlab.net.http.MediaType,
% matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage,
% matlab.net.http.MessageBody, ImageConsumer, FileConsumer

% Copyright 2016-2017 The MathWorks, Inc.
    properties (Access=private)
        Buffer    char
        Boundary  string  % regexp specifying boundary string, which includes CRLF except the first time
        Last      logical % true says we encountered final boundary; rest is Epilogue
        First     logical % true after start, if we haven't gotten first putData call yet
        Done      logical % true if we got putData(uint8.empty) or delegate returned stop=true; reset at start
    end
    
    properties (Constant, Access=private)
        CRLF = char([13 10]); % carriage return+newline
    end
    
    properties (SetAccess=private)
        % Preamble - the part of the multipart message prior to the first boundary
        %   delimiter, if any. This consumer sets this prior to calling start in any
        %   delegate. Its value never changes.
        Preamble  uint8  
        % Epilogue - the part of the multipart message following the last boundary
        %   delimiter, if any. This consumer sets this when the message ends, after
        %   all calls to delegates. It is not set if a delegate terminates the
        %   transfer before the end of the message. You can examine this property
        %   after the transfer is complete (i.e., when RequestMessage.send returns).
        %
        % See also matlab.net.http.RequestMessage
        Epilogue  uint8
    end
    
    properties (Access=private)
        Warned = false % true if we issued a warning for this message
        IsReplace = false; % True if x-mixed-replace
    end

    methods 
        function obj = MultipartConsumer(varargin)
        % MultipartConsumer Construct a multipart consumer
        %   MPCONSUMER = MultipartConsumer(TYPES1, CONSUMER1, TYPES2, CONSUMER2, ...)
        %   MPCONSUMER = MultipartConsumer(PUTHANDLE)
        %     Returns a MultipartConsumer to handle the specified types, or all types.
        %     See GenericConsumer for a description of the arguments.
        %
        % See also GenericConsumer, ContentConsumer    
        
            obj = obj@matlab.net.http.io.GenericConsumer(varargin{:});
        end
        
        function [len, stop] = putData(obj, data)
        % putData Process next buffer of data
        %   [LENGTH, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that accumulates buffers of DATA until an entire part of a
        %   multipart message has been assembled. It then uses the Content-Type field
        %   in the part's header to find an appropriate ContentConsumer delegate that
        %   can handle that type, sets the delegate's Header property to the header
        %   of the part, and then calls initialize and start in that delegate. It
        %   follows that with one or more putData calls, passing in the part's payload,
        %   and then calls putData(uint8.empty) to indicate the end of the payload.
        %
        %   After the final call to the delegate's putData, this method creates a new
        %   ResponseMessage containing the header of the part and a Body copied from
        %   Response.Body in the delegate. (That Body may or may not contain data,
        %   depending on what the delegate does.)  It adds that new ResponseMessage to
        %   the array of ResponseMessages in this consumer's Response.Body.Data
        %   property, which, when the end of the message has been reached, will contain
        %   one ResponseMessage for every part.
        %
        %   If you override this method and return STOP=true before the end of the
        %   message (if DATA is not empty) in order to terminate receipt of the message
        %   before the normal end of message, you should avoid calling this superclass
        %   method on the subsequent putData(uint8.empty) call that MATLAB normally
        %   makes after you set STOP. Failure to do so will result in an invalid
        %   message exception from MultipartConsumer due to a premature end of message.
        %
        % See also ContentConsumer, matlab.net.http.ResponseMessage,
        % matlab.net.http.MessageBody, matlab.net.http.field.ContentTypeField,
        % matlab.net.http.io.ContentConsumer.putData
            if isempty(obj.Boundary)
                % no boundary; just pass to GenericConsumer which will store raw data
                len = obj.putData@matlab.net.http.io.GenericConsumer(data);
                return;
            end
            len = length(data);
            if isempty(data)
                if ~obj.Done
                    % End of message
                    obj.Epilogue = obj.Buffer;
                    if obj.Last
                        % If obj.Last is set, it means we encountered the last boundary
                        % Anything left in the buffer after that is Epilogue
                        obj.Epilogue = obj.Buffer;
                    else
                        error(message('MATLAB:http:MissingEndBoundary'));
                    end
                    obj.Last = false;
                    obj.Done = true;
                    % At end, make sure our superclass doesn't think we still have a delegate, or it
                    % will forward the putData call to the delegate (we already called
                    % PutMethod(uint8.empty) at the end of the last part).
                    obj.PutMethod = [];
                    obj.CurrentDelegate = [];
                    [len, stop] = obj.putData@matlab.net.http.io.GenericConsumer(data);
                else
                    stop = false;
                end
                return;
            end
            % Where to start searching for boundary. We already looked in obj.Buffer,
            % last time into this method, so start after that.
            startSearch = length(obj.Buffer);
            obj.Buffer = [obj.Buffer reshape(data,1,[])]; 
            idx = 0;
            stop = false;
            % loop until buffer contains no more boundary, we get to the last boundary
            % (obj.Last is set), or a consumer says stop
            while ~isempty(idx) && ~stop && ~obj.Last
                % Find start-of-frame boundary marker, which marks the end of the current
                % part. We know it's not fully contained in obj.Buffer prior to startSearch,
                % because we already searched that last time around, so start search 
                % at the last possible place it might be contained. Need to back up
                % by length of boundary in case boundary was split across buffers.
                startIdx = max(startSearch-strlength(obj.Boundary),1);
                [idx,edx] = regexp(obj.Buffer(startIdx:end), obj.Boundary, 'once');
                % if we didn't find a boundary marker, return and keep buffering
                if ~isempty(idx)
                    % found boundary marker in buffer; this means we may have a whole message part
                    % from the beginning of the buffer up to the boundary
                    idx = startIdx + idx - 1; % adjust indices relative to where we started searching
                    edx = startIdx + edx - 1;
                    % extract the part up from beginning up to byte before boundary
                    part = obj.Buffer(1:idx-1);
                    % if last char of boundary is '-' then it's the last part and we should
                    % ignore anything after it, as per RFC 2046
                    obj.Last = obj.Buffer(edx) == '-';
                    if obj.Last
                        % If last part, search past final boundary for CRLF, after which is epilogue.
                        [~,edb] = regexp(obj.Buffer(edx+1:end), ['^.*?' obj.CRLF], 'once');
                        if ~isempty(edb)
                            edx = edx + edb;
                        end
                    end
                    % trim beginning of buffer to remove part just extracted, plus its boundary
                    obj.Buffer(1:edx) = [];
                    % since we stopped the search at edx and now have removed that data,
                    % next search starts at beginning of buffer.
                    startSearch = 1;
                    if obj.First
                        % Part before first boundary is preamble, which we just save
                        obj.Preamble = part;
                        obj.First = false;
                        % Adjust the boundary to add a CRLF. This makes it a delimiter, as per RFC
                        % 20146. But also match a boundary without the CRLF, to account for completely
                        % empty parts (no header or body).
                        obj.Boundary = obj.CRLF + obj.Boundary + '|^' + obj.Boundary;
                        continue
                    end
                    if idx == 1
                        % This happens only if we found 2 boundary markers in a row, implying a
                        % completely empty part. A part should always begin with a header, or a CRLF
                        % if there is no header. Silently ignore parts with no header or CRLF.
                        continue;
                    end
                    % Now part contains is a whole header and data; no boundary markers and no CRLF
                    % that ends the part.
                    
                    % Assemble lines prior to lone CRLF into header, ending at blank line
                    import matlab.net.http.*;
                    
                    idx = 0;
                    
                    % find end of header: an initial CRLF or two CRLF's in a row
                    edx = regexp(part, ['(^|' obj.CRLF ')' obj.CRLF], 'once');
                    if isempty(edx)
                        % no CRLF at beginning of line; this means the part contains only headers, no
                        % body
                        edx = length(part) + 1;
                    elseif edx ~= 1 
                        % header ended by extra CRLF and is nonempty. edx==1 means
                        % that CRLF found at beginning of part (empty header)
                        edx = edx + strlength(obj.CRLF); 
                    else
                    end
                    payloadStart = edx + strlength(obj.CRLF);
                    % edx points to the char after last header line (a CRLF) or past end of buffer
                    % parse names and values of header fields into array of structs. This
                    % expression finds header lines ending in CRLF or at the end of the part.
                    % headers is empty if edx == 1, but could also be empty if no properly formed
                    % header field was found before edx.
                    headers = regexp(part(1:edx-1), ...
                        ['[ \t]*(?<Name>[^\s:]*):[ \t]*(?<Value>\S+([ \t]+\S+)*)[ \t]*(' obj.CRLF '|$)'], 'names');
                    if isempty(headers)
                        headers = HeaderField.empty;
                        if edx ~= 1
                            % There was data in the header, but an actual CRLF-terminated header field was
                            % not found with the syntax "name: value CRLF". Therefore treat the whole
                            % contents as data.
                            if ~obj.Warned
                                warning(message('MATLAB:http:PrematureEndOfPartHeader'));
                                obj.Warned = true;
                            end
                            payloadStart = 1;
                        end
                    else
                        % convert structs to HeaderField subclasses
                        headers = arrayfun(@(h) matlab.net.http.HeaderField.createHeaderField(h.Name,h.Value), ...
                                           headers, 'UniformOutput', false);
                        headers = [headers{:}];
                    end
                    if payloadStart <= length(part)
                        % data block starts after the CRLF that ends header
                        data = uint8(part(payloadStart:end));
                        data = reshape(data,[],1); % make column vector
                    else
                        data = uint8.empty;
                    end
                    % See if there's a Content-Type field in the header. If not add text/plain
                    % as per RFC 2016, section 5.1
                    if isempty(getFields(headers, 'Content-Type'))
                        headers = addFields(headers, matlab.net.http.field.ContentTypeField('text/plain'));
                    end
                    % This sets CurrentDelegate to the appropriate consumer and calls initialize and
                    % start in it.
                    [ok, bufsize] = obj.chooseAndInitializeDelegate(headers);
                    if ok 
                        % Send the data for one part to the delegate. Note that we send data even if
                        % it's empty, as an empty part might have some significance.
                        dlen = length(data);
                        if isempty(bufsize)
                            bufsize = dlen;
                        else
                        end
                        % send at most in increments of the bufsize
                        bufend = 0;
                        if dlen == 0
                            [blen, stop] = obj.putData@matlab.net.http.io.GenericConsumer(uint8.empty, false);
                        else
                            for i = 0 : bufsize : dlen-1
                                bufend = min([i+bufsize dlen]);
                                [blen, stop] = obj.putData@matlab.net.http.io.GenericConsumer(data(i+1:bufend), false);
                                % If blen is negative, it means end the part, but continue normally. If [],
                                % abort the message with an error. If stop is set, end the whole message
                                % gracefully and don't call putData(uint8.empty) at end.
                                if isempty(blen) || blen < 0 || stop 
                                    break;
                                end
                            end
                        end
                        abortWithError = isempty(blen);
                        % The delegate's "response" is a ResponseMessage whose Body
                        % contains whatever the delegate put in it, if any, and whatever headers we
                        % found for the part. If the delegate was just a PUTHANDLE, this
                        % response remains empty.
                        response = matlab.net.http.ResponseMessage([], headers);
                        if ~stop && ~isempty(data) && ~abortWithError
                            % Now tell delegate the part has ended, if we haven't already by sending it
                            % empty data and it didn't tell us to stop. A normal return of endlen here is 0.
                            % If delegate returns endlen = [], it's an error and we end the message. If
                            % delegete sets stop, we end the message but with no error. The false says
                            % don't really end the message by copying the delegate's response to
                            % obj.Response.
                            [endlen, stop] = obj.putData@matlab.net.http.io.GenericConsumer(uint8.empty, false);
                            abortWithError = isempty(endlen);
                        else
                        end
                        if ~isempty(obj.CurrentDelegate)
                            if obj.SavePayload 
                                % if SavePayload set, store the payload in the delegate, in case
                                % the delegate is later queried for the payload
                                obj.CurrentDelegate.Response.Body.PayloadInt = data(1:bufend);
                            end
                            % copy delegate's Body to our response
                            response.Body = obj.CurrentDelegate.Response.Body;
                            assert(~isempty(obj.Response.Body)) % infrastructure should have primed us with empty body
                        else
                        end
                        if obj.IsReplace || isempty(obj.Response.Body.DataInt)
                            % for x-mixed-replace, or the first time, data is the whole response
                            obj.Response.Body.DataInt = response;
                        else
                            % for other multiparts subsequent times, add response to array of responses
                            obj.Response.Body.DataInt(end+1) = response;
                        end
                        if abortWithError
                            % Delegate or superclass had a problem and wants to abort the
                            % whole message. Otherwise we report the original len to our caller.
                            len = [];
                        else
                        end
                    else
                        obj.errorOnNoMatch();
                    end
                end
            end
            if stop
                % delegate told us to stop, so silently finish message with no epilogue
                obj.Done = true;
            end
        end
    end 
    
    methods (Access=protected)
        function ok = initialize(obj)
        % INITIALIZE Prepare this object for use with a new payload
        %   OK = INITIALIZE(CONSUMER) is an overridden method of ContentConsumer that
        %   prepares this consumer for a new message. This method verifies that the
        %   ContentTypeField of the message, if present, has a MediaType whose Type is
        %   "multipart", and that it has a "boundary" parameter indicating the delimiter
        %   between parts. If not, it returns false to indicate it cannot process the
        %   message. It ignores the subtype.
        %
        %   If the ContentTypeField is missing, this consumer just stores all the raw
        %   data in the message Payload.  
        %
        % See also matlab.net.http.io.ContentConsumer.initialize
            ok = obj.initialize@matlab.net.http.io.GenericConsumer;
            if ~ok || (~isempty(obj.ContentType) && ~strcmp(obj.ContentType.Type, 'multipart'))
                ok = false;
                return
            end
            ok = true;
            % Don't call start in our superclass because it tries to delegate to a
            % consumer that supports the message's Content-Type. Since it's multipart,
            % then it would just be us.
            if ~isempty(obj.ContentType)
                boundary = obj.ContentType.getParameter('boundary');
                if isempty(boundary)
                    error(message('MATLAB:http:BoundaryMissing'));
                end
                boundary = matlab.net.internal.getSafeRegexp(boundary);
                % this matches a dash-boundary or closer-delimiter of RFC 2046
                LWSPchar = '[ \t]*';
                obj.Boundary = '--(' + boundary + LWSPchar + obj.CRLF + ...
                     '|' + boundary + '--' + LWSPchar + ')';
                 
                % this says each part replaces the previous part; otherwise we keep
                % adding to previous parts
                obj.IsReplace = strcmpi(obj.ContentType.Subtype, "x-mixed-replace");
            end
        end 
        
        function bufsize = start(obj)
        % START Start transfer of data
        %   BUFSIZE = START(CONSUMER) is an abstract method of ContentConsumer that
        %   prepares CONSUMER for receipt of data. This method always returns [] to
        %   indicate it has no preferred buffer size. 
        %
        % See also matlab.net.http.io.ContentConsumer.start
        
            % If there is a ContentType, verify it's multipart; if none, assume it is.
            obj.Warned = false;
            obj.Response.Body.Data = matlab.net.http.ResponseMessage.empty;
            obj.Last = false;
            obj.First = true;
            obj.Done = false;
            obj.Preamble = [];
            obj.Epilogue = [];
            obj.Buffer = [];
            bufsize = [];
        end
    end
end
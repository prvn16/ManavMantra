classdef MultipartProvider < matlab.net.http.io.ContentProvider
% MultipartProvider ContentProvider for multipart/mixed HTTP messages
%   This is provider assists in the creation of multipart HTTP messages. The
%   default Content-Type is "multipart/mixed", and the payload of the message
%   contains an arbitrary number of parts, each part containing its own header
%   describing that part. For more information on multipart messages, see
%   RFC 2046, <a href=https://tools.ietf.org/html/rfc2046#section-5.1>section 5.1</a>.
%
%   Use this provider directly only if you know your server accepts multipart/mixed
%   messages. In most cases, servers that accept multipart messages will
%   instead require multipart/form-data, which is implemented by the subclass
%   MultipartFormProvider. You can implement other multipart types using
%   subclasses.
%
%   MultipartProvider methods:
%     MultipartProvider - constructor
%
%   MultipartProvider properties:
%     Parts      - cell array of parts
%     Subtype    - subtype of the media type
%
%   For subclass authors
%   --------------------
%
%   Each of the parts of the multipart message may be specified as data in any
%   of the formats permitted for RequestMessage.Body, or as a ContentProvider
%   that creates the data. The ContentProviders that are used to supply data for
%   the parts are called delegates, while this MultipartProvider is the top
%   level provider. In general, any ContentProvider is suitable as a delegate.
%   The MultipartProvider invokes each delegate in turn as the message is being
%   sent, calling its methods such as complete, start, etc., so that the
%   delegate in general need not be aware that it is providing content for a
%   part, rather than for a whole message.
%
%   This provider always forces the RequestMessage to be transmitted as chunked,
%   so it does not include a Content-Length header field in the message or in
%   the headers of any of the parts. While it calls each delegate's
%   expectedContentLength method prior to sending the part, it uses the return
%   value (if nonempty) only to enforce the length, not to create a Content-Length
%   field. If the delegate does want a Content-Length field to appear in the
%   part, it must insert such a field explicitly in its Header property. None
%   of MATLAB's supplied ContentProvider subclasses do this.
%
%   MultipartProvider methods:
%     complete   - complete header of message
%     start      - start the message
%     getData    - return next buffer of data
%
% See also ContentProvider, MultipartFormProvider,
% matlab.net.http.RequestMessage, start, complete, expectedContentLength, Header

% Copyright 2017 The MathWorks, Inc.
    
    properties (Dependent)
        % Parts - cell array of parts, as provided to constructor
        %   Each element of the cell array can be an array of parts. Parts consisting
        %   of data or MessageBody arrays are converted to RequestMessage object arrays.
        %   Subclasses may set this directly in their constructors, or any time before
        %   the first call to getData.
        %
        % See also MultipartProvider.MultipartProvider, getData
        Parts cell
    end
    
    properties (Access=private, Transient)
        % Index of the current part in Parts array; 
        % This is bumped (and GetDataFcn cleared) when getDataFcn() returns [].
        % This is 0 initially and after message is completed or errors.
        CurrentPartIndex double = 0
        % Index of the sub-part of the current part at Parts{CurrentPartIndex}. This is
        % used in the case of a part being a non-scalar array of ContentProvider,
        % RequestMessage or MessageBody. This is bumped after getDataFcn() of the
        % sub-part returns [], but only if it is not already 0. For other types, this
        % value remains at 0.
        CurrentSubpartIndex double = 0
    end
    
    properties (Hidden, Access=?matlab.net.http.io.ContentProvider)
        % Handle to the current delegate's getData method. The current delegate is at
        % RealParts{CurrentPartIndex} or RealParts{CurrentPartIndex}(CurrentSubpartIndex). 
        % If empty, we haven't called the delegate's getData method yet, so this is
        % cleared every time we bump CurrentSubpartIndex or CurrentPartIndex.
        GetDataFcn function_handle
    end
    
    properties (Access=private)
        % Boundary delimiter as vector. This remains constant once it is set.
        BoundaryDelimiter char
        % The URI
        URI matlab.net.URI
        % If the current part being sent (RealParts{obj.CurrentPartIndex}) is a
        % RequestMessage whose Body is a MessageBody instead of a ContentProvider, then
        % this is the index of the next byte of that Body's Payload to be sent by
        % getDataFromBody. Otherwise it's [].
        PayloadOffset uint64
        % The real parts
        RealParts cell
    end

    properties (Access=protected)
        % Subtype - the subtype for this provider
        %   Default value is "mixed", which causes the header of the message to contain
        %   a Content-Type of "multipart/mixed", plus appropriate parameters. Subclasses
        %   may alter this value in their constructor or complete method. This value
        %   will appear in the Content-Type after "multipart/".
        %
        % See also complete
        Subtype string = "mixed";
    end
    
    properties (Constant, Access=private)
        CRLF = char([13 10]); % carriage return+newline
    end
    
    methods
        function set.Parts(obj, value)
            if ~isempty(value)
                validateattributes(value, {'cell'}, {'vector'}, mfilename);
                if obj.CurrentPartIndex > 0 
                    error(message('MATLAB:http:CannotChangeParts'));
                end
            end
            obj.RealParts = value;
        end
        
        function value = get.Parts(obj)
            value = obj.RealParts;
        end
        
        function obj = MultipartProvider(varargin)
        % MultipartProvider MultipartProvider constructor
        %  PROVIDER = MultipartProvider(PART1, PART2, ...) constructs a
        %    MultipartProvider that will send the specified PARTs, in the specified
        %    order, in an HTTP request. By default this provider sets the Content-Type
        %    of the message to "multipart/mixed", but subclasses may alter the subtype
        %    by setting the Subtype property.
        %
        %    Each PART can be one of the following:
        %
        %    ContentProvider object
        %       The MultipartProvider will delegate creation of the part to the
        %       specified provider (called the delegate), invoking its complete method
        %       to obtain header information about the part and its getData method to
        %       obtain the data. The delegate's Header property will be used for the
        %       header of the part. Any subclass of ContentProvider may be specified
        %       here. Normally, the delegate need not specify the content length nor
        %       implement the expectedContentLength method, since the end of a part is
        %       designated by a boundary string rather than a header field. If that
        %       method is implemented to return a nonempty value, the value will be used
        %       only to enforce the length of the content, not to create a
        %       Content-Length field.
        %
        %    RequestMessage object
        %       The MultipartProvider will send the Header and Body of the
        %       RequestMessage as the part. If the Body's Payload property is set, that
        %       will be used for the raw payload. Otherwise the Body's Data property
        %       will be converted based on its type or the Content-Type field in the
        %       Header, as described for MessageBody.Data. This option is useful if you
        %       have data to send and want to take advantage of the default processing
        %       of that data that MATLAB normally does when sending a RequestMessage. It
        %       allows you to specify custom header fields in the request that will be
        %       used as the part's Header and control how the data is converted,
        %       without having to write a ContentProvider subclass. The
        %       RequestMessage.RequestLine property is ignored.
        %
        %    MessageBody object
        %       The MessageBody will be processed the same as if it was in a
        %       RequestMessage that had no Content-Type field. This option is useful if
        %       default processing of the data based on its type is sufficient, and you
        %       do not need to specify any custom header fields for the part. MATLAB
        %       will insert a Content-Type field in the part based on the type of the
        %       the data. See MessageBody.Data for conversion rules.
        %    
        %    Array of above (not cell array)
        %       This treats each element of the array as a part.
        %
        %    Handle to a getData method
        %       This method must have the signature of ContentProvider.getData. In this
        %       case the part's Content-Type is set to "application/octet-stream", so
        %       this option is useful for sending binary data. When using this option
        %       you cannot specify any custom header fields for the part.
        %
        %    Any other type
        %       If the type of PART does not match any of above and is not a function
        %       handle, it will be treated as if it was present in the Data property of
        %       a MessageBody. See MessageBody above.
        %
        % See also ContentProvider, matlab.net.http.RequestMessage,
        % matlab.net.http.MessageBody, getData, Subtype
            obj.RealParts = varargin;
            for i = 1 : nargin
                arg = varargin{i};
                if isa(arg, 'function_handle') && ...
                   (nargin(arg) < 1 || nargout(arg) == 1 || nargout(arg) == 0)
                    error(message('MATLAB:http:BadGetDataMethod', i));
                end
            end
        end
        
        function [data, stop] = getData(obj, length)
        % getData Get the next buffer of data
        %   [DATA, STOP] = getData(OBJ, LENGTH) is an implementation of the
        %   ContentProvider's abstract getData method. For each part of the multipart
        %   message, this method returns in successive buffers of DATA: a boundary
        %   delimiter, headers for the part, and the data for the part. It obtains these
        %   by invoking methods in the current delegate, including the delegate's
        %   getData method, and moves on to the next delegate when the current delegate
        %   indicates the end of its data by returning STOP=true.
        %
        %   When the last delegate is done, this method returns the final boundary
        %   delimiter and then sets STOP=true to indicate the end of the message.
        %
        % See also matlab.net.http.io.ContentProvider.getData
            if obj.CurrentPartIndex > numel(obj.RealParts)
                % all done; send final boundary delimiter
                data = uint8([obj.CRLF '--' obj.BoundaryDelimiter '--' obj.CRLF]);
                obj.CurrentPartIndex = 0;
                stop = true;
            else
                % there is a delegate at RealParts{obj.CurrentPartIndex}
                if isempty(obj.GetDataFcn)
                    % We don't have a delegate. This is the first time or after previous delegate
                    % has ended. CurrentPartIndex is the part we're on or haven't started yet.
                    % CurrentSubpartIndex is > 0 if we're still in a part that had subparts. Get
                    % next delegate and set GetDataFcn.
                    if obj.CurrentSubpartIndex > 0 && obj.CurrentSubpartIndex == numel(obj.RealParts{obj.CurrentPartIndex})
                        % Current part has sub-parts, but we're done with them; bump counters and
                        % recurse to get next delegate. If no more delegates, this returns the final
                        % boundary delimiter and sets stop
                        obj.CurrentPartIndex = obj.CurrentPartIndex + 1;
                        obj.CurrentSubpartIndex = 0;
                        obj.GetDataFcn = function_handle.empty;
                        [data, stop] = obj.getData(length); % recurse
                        data = reshape(data,1,[]);
                        return;
                    else
                        % Current part has no subparts, or it still has another subpart.
                        % If CurrentSubpartIndex is 0, this bumps CurrentPartIndex
                        % and sets CurrentSubpartIndex to 0 or 1 depending on whether the
                        % new part has subparts. If CurrentSubpartIndex is > 0, bumps
                        % CurrentSubpartIndex. Get the delegate and its header.
                        header = obj.getDelegate();
                        % prepend boundary to header of part, except very first part gets no CRLF in
                        % front of it
                        if obj.CurrentPartIndex == 1 && obj.CurrentSubpartIndex < 2
                            data = uint8(['--' obj.BoundaryDelimiter obj.CRLF header]); 
                        else
                            data = uint8([obj.CRLF '--' obj.BoundaryDelimiter obj.CRLF header]); 
                        end
                    end
                else
                    data = [];
                end
                % call getData in the delegate
                try
                    [newData, stop] = obj.GetDataFcn(length);
                catch e
                    % Any exception in the delegate resets this provider for reuse
                    obj.CurrentPartIndex = 0;
                    rethrow(e);
                end
                newData = reshape(newData,1,[]);
                data = [data newData];
                if stop
                    % delegate has no more data; end it
                    obj.GetDataFcn = function_handle.empty;
                    % Advance to the next delegate. If no more delegates, the next call to getData
                    % will return the final boundary delimiter and set stop.
                    if obj.CurrentSubpartIndex == 0
                        % If there are no subparts to the current part, increment the index to advance
                        % to the next part. If there are subparts, the next call will decide
                        % whether to advance to the next part or subpart
                        obj.CurrentPartIndex = obj.CurrentPartIndex + 1;
                    end
                    stop = false;
                end
            end
        end
    end
       
    methods (Access=protected)
        function start(obj)
        % start Start a new transfer
        %   START(PROVIDER) is an abstract method of ContentProvider that MATLAB calls
        %   to start transfer of the data from this provider. This method resets the
        %   provider so that the next call to getData starts the first delegate.
        %
        % See also matlab.net.http.io.ContentProvider.start, delegateTo
            obj.CurrentPartIndex = 1;
            obj.CurrentSubpartIndex = 0;
            obj.GetDataFcn = function_handle.empty;
            obj.start@matlab.net.http.io.ContentProvider();
        end
        
        function complete(obj, uri)
        % complete Complete the header of the message
        %   complete(PROVIDER, URI) is an overridden method of ContentProvider that adds
        %   a "multipart/subtype" Content-Type field to the RequestMessage, with
        %   appropriate parameters. The subtype is taken from the value of the Subtype
        %   property, which is, by default, "mixed". If the message already contains a
        %   Content-Type field, it is preserved. If the field contains a "boundary"
        %   parameter, the value of the parameter becomes the boundary delimiter. If it
        %   does not contain such a value, and the type is "multipart", then a boundary
        %   parameter is generated and added to the field. If changed or added, the new
        %   ContentTypeField is inserted in this provider's Header property.
        %
        %   Subclasses that extend MultipartProvider can specify their own subtype and
        %   other parameters by calling this method first and then modifying the
        %   ContentTypeField in Header.
        %
        % See also matlab.net.http.io.ContentProvider.complete, matlab.net.http.Header,
        % matlab.net.http.field.ContentTypeField
            if isempty(obj.RealParts)
                error(message('MATLAB:http:EmptyMultipart'));
            end
            obj.URI = uri;
            % See if there's already a Content-Type field in Header or Request. Our
            % superclass should be priming Header with any fields, but just in case it does,
            % look there first.
            ctf = obj.Header.getValidField('Content-Type');
            inHeader = ~isempty(ctf);
            if inHeader
                mt = ctf.convert();
            end
            if isempty(ctf) || isempty(mt)
                % no nonempty Content-Type field in message, so create a boundary delimiter
                obj.BoundaryDelimiter = getBoundaryDelimiter();
                if isempty(ctf) 
                    % If there was no Content-Type field in the Requst or in Header, create one and
                    % add it to header. If there was one but it was empty, don't add it, as an empty
                    % field is intended to suppress adding a field automatically.
                    obj.Header = obj.Header.addFields(matlab.net.http.field.ContentTypeField( ...
                        matlab.net.http.MediaType("multipart/" + obj.Subtype, 'boundary', obj.BoundaryDelimiter)));
                end
            else
                % Found a nonempty Content-Type field; mt is a MediaType. If the Type is
                % multipart, get or set its boundary delimiter. If not, generate a boundary
                % delimiter to use for this message but don't add it to the field.
                isMultipart = strcmpi(mt.Type, 'multipart');
                if isMultipart
                    obj.BoundaryDelimiter = mt.getParameter('boundary');
                end
                if isempty(obj.BoundaryDelimiter)
                    obj.BoundaryDelimiter = getBoundaryDelimiter();
                    if isMultipart
                        mt = mt.setParameter('boundary',obj.BoundaryDelimiter);
                        ctf = matlab.net.http.field.ContentTypeField(mt);
                        assert(inHeader)
                        obj.Header = obj.Header.changeFields(ctf);
                    end
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

    methods (Access=?matlab.net.http.io.MultipartFormProvider)
        % This method is really Access=protected, but we want to limit it to only our
        % own subclasses for now.
        
        function headers = completePart(~, ~, ~, headers)
        % completePart complete the next part
        %  HEADERS = completePart(PROVIDER, INDEX, SUBINDEX, HEADERS) completes the next part
        %    MultipartProvider calls this method when it is about to start transmitting
        %    a new part or subpart, after it has assembled the headers for the part.
        %    PROVIDER.Parts{INDEX}(SUBINDEX) is the part/subpart to be started, HEADERS
        %    is an array of HeaderField for the part. If the part is an array of
        %    ContentProviders, then MultipartProvider calls this method after calling
        %    delegateTo in the part.
        %
        %    The purpose of this method is to give subclasses of MultipartProvider an
        %    opportunity to initialize the header for the part, or augment the header
        %    initialized by delegateTo, with any information specific to the part.
        %
        %    By default this method does nothing. 
        end
    end
    
    methods (Access=private)
        function headers = getDelegate(obj,~)
        % getDelegate(flag) - start up the delegate at RealParts{CurrentPartIndex} and store a handle to its
        %   getData method in obj.GetDataFcn. If RealParts{CurrentPartIndex} is empty,
        %   set GetDataFcn to []. Return the header of the part. The flag argument, if
        %   present, is set only for internal purposes on a recursive call.
            import matlab.net.http.RequestMessage
            import matlab.net.http.field.ContentTypeField

            delegate = obj.RealParts{obj.CurrentPartIndex};
            
            if isa(delegate, 'matlab.net.http.io.ContentProvider')
                if numel(delegate) > 1
                    % if there's more than one delegate in the array, get the current one
                    obj.CurrentSubpartIndex = obj.CurrentSubpartIndex + 1;
                    delegate = delegate(obj.CurrentSubpartIndex);
                end
                obj.GetDataFcn = obj.delegateTo(delegate, obj.URI);
                headers = delegate.Header;
            elseif isa(delegate, 'matlab.net.http.RequestMessage')
                if numel(delegate) > 1
                    obj.CurrentSubpartIndex = obj.CurrentSubpartIndex + 1;
                    delegate = delegate(obj.CurrentSubpartIndex);
                end
                % If the delegate is a RequestMessage, completes the payload (e.g., copying Data
                % to Payload with conversion) and augment header as appropriate. Note that if
                % this a strange case where the RequestMessage contains a ContentProvider, that
                % provider's complete method will be called which causes any of its headers to
                % be merged into those of the RequestMessage.
                msg = delegate; 
                msg = msg.completeBody(obj.URI);
                ctf = msg.Header.getValidField('Content-Type');
                isBody = isa(msg.Body, 'matlab.net.http.MessageBody');
                if isempty(ctf) && isBody
                    msg = msg.addFields(ContentTypeField(msg.Body.ContentType));
                end
                obj.RealParts{obj.CurrentPartIndex}(max([1,obj.CurrentSubpartIndex])) = msg;
                headers = msg.Header;
                if isempty(msg.Body) || isBody
                    % normal case: Body is a MessageBody
                    obj.PayloadOffset = 1;
                    obj.GetDataFcn = @obj.getDataFromBody;
                else
                    % strange case: Body is another ContentProvider; start it and use its getData method
                    assert(isa(msg.Body, 'matlab.net.http.io.ContentProvider'))
                    obj.GetDataFcn = @(varargin)msg.Body.getDataInternal(varargin{:}); 
                    msg.Body.startInternal();
                end
            elseif isa(delegate,'function_handle')
                headers = ContentTypeField(matlab.net.http.MediaType('application/octet-stream'));
                obj.GetDataFcn = delegate;
            else 
                % MessageBody array or some other type
                if isa(delegate, 'matlab.net.http.MessageBody') 
                    % delegate is MessageBody array. Replace with array of RequestMessage. We'll
                    % no longer come here for this CurrentPartIndex
                    obj.RealParts{obj.CurrentPartIndex} = arrayfun(@(p) RequestMessage([],[],p), delegate);
                else
                    % delegate is data. Replace with scalar RequestMessage containing the data This
                    % could error out if data is not acceptable to RequestMessage
                    obj.RealParts{obj.CurrentPartIndex} = RequestMessage([],[],delegate);
                end
                % recurse, but don't bump the delegate index
                headers = obj.getDelegate(true);
                return;
            end
            headers = obj.completePart(obj.CurrentPartIndex, obj.CurrentSubpartIndex, headers);
            % this returns the stringified headers with CRLF between them
            headers = strjoin(arrayfun(@char, headers, 'UniformOutput', false), obj.CRLF);
            if isempty(headers)
                % if no headers, just an empty CRLF
                headers = obj.CRLF;
            else
                % otherwise, follow last header with two CRLFs
                headers = [headers obj.CRLF obj.CRLF];
            end
        end
    
        function [data, stop] = getDataFromBody(obj, len)
        % getFromBody - implements the getData() function for a part specified as, or
        %   that was converted to, a RequestMessage containing data in its Body.
            body = obj.RealParts{obj.CurrentPartIndex}(max([1,obj.CurrentSubpartIndex])).Body;
            if isempty(body) || isempty(body.Payload)
                data = [];
                stop = true;
            else
                assert(isa(body, 'matlab.net.http.MessageBody'));
                endOffset = obj.PayloadOffset + len - 1;
                data = body.Payload(obj.PayloadOffset : min([endOffset length(body.Payload)]));
                obj.PayloadOffset = endOffset + 1;
                stop = obj.PayloadOffset >= length(body.Payload);
            end
        end
    end
end

function delimiter = getBoundaryDelimiter()
% Return a new random boundary delimiter
    persistent chars
    if isempty(chars)
        % chars allowed in boundary delimiter as per
        % https://tools.ietf.org/html/rfc2046#section-5.1.1
        chars = ['a':'z' 'A':'Z' '0':'9' '''()+_,-./:=?'];
    end
    % Generate a delimiter from 20 random characters in above set, preceded by
    % a bunch of dashes.
    delimiter = ['-----------------' chars(randi(length(chars), 1, 20))];
end


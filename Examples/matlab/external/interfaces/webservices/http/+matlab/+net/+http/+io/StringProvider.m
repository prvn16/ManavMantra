classdef StringProvider < matlab.net.http.io.ContentProvider
% StringProvider ContentProvider that sends a MATLAB string
%   This provider helps you send a MATLAB string or character vector in a
%   RequestMessage. By default, if a RequestMessage.Body.Data contains a string
%   or character vector, it is converted to binary according to the encoding
%   (charset) specified (or implied) by the Content-Type field in the message,
%   so you would not normally need to use this object to send plain text in
%   cases where MATLAB can determine what encoding to use.
%
%   Use this object in a Request.Body to send a string encoded using a charset
%   that might be different from the one that MATLAB would use for the
%   Content-Type in the header. You specify that charset in the ContentProvider
%   constructor or by setting the Charset property. If the message contains no
%   Content-Type, this provider adds one specifying text/plain and the
%   specified charset.
%
%   The following prepares a message that will send the string "foo" to the
%   using the Content-Type text/plain to the server using Shift_JIS encoding:
%
%     ctf = ContentTypeField(MediaType('text/plain','charset','Shift_JIS');
%     r = RequestMessage('put',ctf,StringProvider('foo'));
%
%   In this example, the header has no Content-Type field, so StringProvider
%   inserts one based on the constructor arguments.
%
%     r = RequestMessage('put',[],StringProvider('foo','Shift_JIS'));
%     show(r.complete('www.foo.com'))
%     PUT / HTTP/1.1
%     Host: www.foo.com
%     Content-Type: text/plain; charset=Shift_JIS
%     User-Agent: MATLAB/9.2.0.512567 (R2017b)
%     Connection: close
%     Date: Fri, 20 Jun 2017 14:26:42 GMT
%
%   In this example, the charset specified to the StringProvider constructor
%   used to convert the data is different from the charset in the Content-Type
%   field. StringProvider does not alter an existing Content-Type field that
%   already specifies a character set, so the server will assume the data is
%   US-ASCII, not Shift-JIS.
%
%     ctf = ContentTypeField(MediaType('text/plain','charset','US-ASCII'));
%     r = RequestMessage('put',ctf,StringProvider('foo','Shift_JIS'));
%
%   In this example, MATLAB adds a charset parameter to the Content-Type field
%   that did not specify a charset, because the default for "application/json" is
%   UTF-8, which is different from Shift_JIS.
%
%     ctf = ContentTypeField(MediaType('application/json'));
%     r = RequestMessage('put',ctf,StringProvider('foo','Shift_JIS'));
%     show(r.complete('www.foo.com'))
%     PUT / HTTP/1.1
%     Host: www.foo.com
%     Content-Type: application/json; charset=Shift_JIS
%     User-Agent: MATLAB/9.2.0.512567 (R2017b)
%     Connection: close
%     Date: Fri, 20 Jun 2017 14:26:42 GMT
%
%   When there is no Content-Type header field and no charset is specified to
%   StringProvider, MATLAB uses a heuristic to find a the "minimal" encoding
%   that can represent the data, one of which includes the default encoding for
%   the platform. In this example, when run on Windows, the Unicode characters
%   in the string are within the Windows-1252 range, but outside the US-ASCII
%   range, so Windows-1252 is used:
%
%     r = RequestMessage('put',[],StringProvider('€abc'));
%     show(r.complete('www.foo.com'))
%     PUT / HTTP/1.1
%     Host: www.foo.com
%     Content-Type: text/plain; charset=windows-1252
%     User-Agent: MATLAB/9.2.0.512567 (R2017b)
%     Connection: close
%     Date: Fri, 20 Jun 2017 14:26:42 GMT
%
%   In this case, the Content-Type field specifies application/json with no
%   charset, and none is specified to StringProvider. Since the default charset
%   for application/json is UTF-8, StringProvider uses that to convert and does
%   not specify this explicitly in the Content-Type field.
%
%     ctf = ContentTypeField(MediaType('application/json'));
%     r = RequestMessage('put',ctf,StringProvider('foo')); % uses UTF-8
%
%   StringProvider properties:
%     Data        - the data to be sent
%     Charset     - character set used for encoding
%
%   StringProvider methods:
%     StringProvider - constructor
%     string, show   - display contents of string
%
%   For subclass authors
%   --------------------
%
%   If you are creating your own ContentProvider that generates character-based
%   data, it may be useful to subclass this provider to convert your output to
%   the appropriate character set. To do so, set Charset to the desired
%   character set in your complete method, prior to calling the superclass
%   complete method. In your getData method, generate a buffer of data and call
%   the superclass getData to convert it.
%
%   StringProvider methods (overridden methods of ContentProvider):  
%     start          - start a new transfer
%     getData        - get next buffer of data
%     complete       - complete headers

% Copyright 2017 The MathWorks, Inc.
    properties (Dependent)
        % Data - the data to be sent
        %   This is the value of DATA that was provided to the StringProvider
        %   constructor. You may also set this property directly, after calling the
        %   constructor, or in your subclass. You may set this to a character vector or
        %   scalar string.
        %
        %   Subclasses of StringProvider may assign this property to 
        %
        %   Subclass authors may set this property to new data at any time. The next
        %   call to getData will convert this data, up to the value of getData's LENGTH
        %   argument.
        %
        % See also StringProvider.StringProvider, getData
        Data

        % Charset - character set used for encoding
        %   This is the scheme to use for character encoding. 
        %
        %   The default value, '', says to use the charset in or implied by the
        %   Content-Type header field of the message, or an encoding based on the data
        %   if there is no such field or if the field is missing an explicit charset.
        %   In the last case, a charset will be added to the field to indicate the
        %   chosen encoding. 
        %
        %   If specified, this property must be set to a string or character vector
        %   acceptable as the ENCODING argument to unicode2native. This charset will be
        %   used for encoding and, if there is a Content-Type field with no explicit
        %   charset, and this property is different from that Content-Type's
        %   default charset, a charset parameter will be added to the field. If there
        %   is a charset parameter in the Content-Type field, it will be left
        %   unchanged, even if this Charset property has a different value.
        %
        %   Subclasses of StringProvider may set this value in their getData method
        %   to change the encoding for subsequent characters. For example an HTML 4
        %   document may start out as US-ASCII, but its <meta> tag may specify a "UTF-8"
        %   charset. The provider can return the first part of the document using
        %   US-ASCII conversion, and then change it to UTF-8 after reading the charset
        %   property, for converting the remainder of the document. (Of course, since
        %   US-ASCII is a subset of UTF-8, the provider could just as easily have used
        %   UTF-8 from the start, but this example illustrates the option to change
        %   Charset in the middle of the message.)  
        %
        %   If this property was initially empty, MATLAB sets this property to the
        %   chosen charset. If this provider is reused for a different message that has
        %   a different charset, MATLAB changes this property to the new charset. If
        %   you set this parameter to a nonempty value, MATLAB never changes it.
        %
        % See also unicode2native, ContentTypeField, RequestMessage
        Charset char
    end
    
    properties (Transient, Access=private)
        Offset uint64       % next byte offset to send in obj.Data or obj.ConvertedData
        ConvertedData uint8 % if not empty, send this instead of Data
        RealCharset char = '' 
        UseDefaultCharset = true; % true if user specified no Charset or set it to empty
        RealData
    end
    
    methods
        function set.Data(obj, value)
            if isempty(value) || ...
                    (ischar(value) && isvector(value) && isrow(value)) || ...
                    (isstring(value) && isscalar(value))
                obj.RealData = value;
                obj.ConvertedData = [];
                obj.Offset = 0; 
            else
                validateattributes(value, {'char' 'string'}, {'scalartext'}, ...
                    mfilename, 'Data');
            end
        end
        
        function value = get.Data(obj)
            value = obj.RealData;
        end
        
        function set.Charset(obj, value)
            if isempty(value)
                obj.UseDefaultCharset = true;
            else
                try
                    % do this just to see if charset is valid
                    unicode2native('', value);
                catch
                    error(message('MATLAB:unicodeconversion:InvalidCharset', value));
                end
                obj.UseDefaultCharset = false;
            end
            obj.RealCharset = value;
        end
        
        function value = get.Charset(obj)
            value = obj.RealCharset;
        end
        
        function obj = StringProvider(data,charset)
        % StringProvider Constructor for StringProvider
        %   PROVIDER = StringProvider(DATA,CHARSET) constructs a StringProvider that
        %   will send the specified DATA (a string or character vector) encoded with the
        %   specified CHARSET. Both arguments are optional. If not specified, you can
        %   set them later in the Data and Charset properties, prior to sending a
        %   message that contains this provider. See the Data and Charset properties
        %   for more information about these properties.
        %
        % See also Data, Charset
            if nargin > 0
                obj.Data = data;
                if nargin > 1
                    obj.Charset = charset;
                end
            end
        end
        
        function [data, stop] = getData(obj, length)
        % getData - return next buffer of data
        %   [DATA, STOP] = getData(PROVIDER, LENGTH) is an overridden method of ContentProvider
        %   that returns the next buffer of data. It normally returns at least LENGTH
        %   bytes (up to the length of the Data property), as a uint8 vector, by reading
        %   up to LENGTH characters from Data, but, depending on the characters in Data
        %   and Charset, the result may be much longer than LENGTH.
        %
        %   Subclasses that generate their own buffers of data in an overridden getData
        %   method, but which want to take advantage of code conversion provide by this
        %   method, should set Data to their buffer of data and call this superclass
        %   getData method to convert Data to the desired charset. In that call,
        %   specify a value of LENGTH at least as big as the number of characters in the
        %   buffer, or only part of the Data will be converted. For example:
        %
        %     function [data, stop] = getData(obj, length)
        %         obj.Data = generateNextBufferOfData(obj);
        %         if isempty(obj.Data)
        %             stop = true;
        %         else
        %             [data, stop] = getData(obj, strlength(obj.Data);
        %         end
        %     end
        %
        % See also Data, Charset, matlab.net.http.io.ContentProvider.getData
        
            % send ConvertedData, if set, or convert Data and send it
            if isempty(obj.ConvertedData)
                % no data was converted yet; data is a string or char vector
                data = obj.Data;
                if isempty(data)
                    dataLen = 0;
                else
                    dataLen = strlength(data);
                end
            else
                % data was converted; data is a uint8 vector
                data = obj.ConvertedData;
                dataLen = numel(data);
            end
            if obj.Offset > dataLen
                data = [];
                stop = true;
            else
                dataEnd = min([obj.Offset + length - 1, dataLen]);
                if isempty(obj.ConvertedData)
                    % get chars from data and convert them
                    if ischar(data)
                        data = data(obj.Offset:dataEnd);
                    else
                        data = extractBetween(data, obj.Offset, dataEnd);
                    end
                    % this may return more data than length, but that's allowed
                    data = unicode2native(char(data), obj.RealCharset);
                else
                    % get already-converted uint8 data
                    data = data(obj.Offset : dataEnd);
                end
                obj.Offset = dataEnd + 1;
                stop = obj.Offset > dataLen;
            end
        end
        
        function str = string(obj)
        % STRING Get string being converted by this provider
        %   STR = STRING(OBJ) returns the contents of the Data property as a string,
        %   or an empty string if Data is not set. This information is also returned by
        %   SHOW.
        %
        % See also Data, show
            if isempty(obj.Data)
                str = "";
            else
                str = string(obj.Data);
            end
        end
    end
    
    methods (Access=protected)
        function complete(obj, varargin)
        % COMPLETE - complete headers in preparation for sending
        %   COMPLETE(PROVIDER, URI) is an overridden method of ContentProvider called by
        %   MATLAB to complete the message. This method may augment or add a
        %   Content-Type header field to the message to specify the charset that this
        %   provider is using to convert the data. The conversion to be used depends on
        %   the value of the Content-Type field in Header or Request.Header, if present
        %   (which may have an explicit or default charset), and the value of the
        %   Charset property in this object. This provider may add a Content-Type field
        %   or charset parameter to the existing Content-Type field, if it does not
        %   contain one. To prevent that, subclasses can override this method.
        %
        %   In contrast to some other providers that only replace, not alter, a header
        %   already in the RequestMessage, this provider may augment an existing
        %   Content-Type field in Request by adding a charset parameter, if necessary.
        %
        %   On return from this method, the Charset property is always set to the
        %   charset that will be used to encode the data, whether or not that charset is
        %   explicit in the Content-Type field. Subclasses can override this method to
        %   specify a different Charset.
        %
        % See also Charset, Request, Header, matlab.net.http.io.ContentProvider.complete
        
        % A rather complex mix of cases that tries to do the right thing; no need to
        % document these all.
        %
        %   Content-Type/    PROVIDER   Conversion charset      New Content-Type 
        %      charset        Charset     derived from            -New/added Charset              
        %   -------------    ---------  ----------------------  ----------------
        %   no Content-Type     ''      Data or platform*       text/plain 
        %                                                         -conversion charset if non-ASCII
        %   no Content-Type  nonempty   PROVIDER.Charset        text/plain
        %                                                         -PROVIDER.Charset if non-ASCII
        %   yes/no default      ''      Data or platform*       unchanged
        %                                                         -Conversion charset
        %   yes/no default   nonempty   PROVIDER.Charset        unchanged
        %                                                         -PROVIDER.Charset
        %   yes/has default     ''      Data if not subset      unchanged
        %                                 of default              -Data if different from default
        %   yes/has default  nonempty   PROVIDER.Charset        unchanged
        %                                                         -PROVIDER.Charset, if different from default
        %   yes/explicit        ''      explicit charset        unchanged
        %                                                         -unchanged
        %   yes/explicit     nonempty   PROVIDER.Charset        unchanged
        %                                                         -unchanged
        % Definitions:
        %    yes = Content-Type is nonempty
        %    no default = we don't know the default charset for the Content-Type, or there
        %       is no default
        %    has default = Content-Type has known default charset
        %    explicit = charset explicitly specified
        % *If the Data property is set, examine the data to derive a charset necessary
        %  to represent the characters in it; if Data is not set, use MATLAB's default
        %  encoding.
            import matlab.net.http.field.*
            import matlab.net.http.*
            obj.complete@matlab.net.http.io.ContentProvider(varargin{:});
            % get the Content-Type header field; we'll treat a missing one the same as an
            % empty one
            ctf = obj.Header.getValidField('Content-Type');
            % get the MediaTypes from the Content-Type fields
            if ~isempty(ctf) 
                mt = ctf.convertNonempty();
            else
                mt = MediaType.empty;
            end
            if isempty(mt)
                % add a Content-Type field if missing or empty
                mt = MediaType('text/plain');
                ctf = ContentTypeField(mt);
                obj.Header = obj.Header.addFields(ctf);
            else
                mt = mt(end); % just use last one, if more than one
            end
            % At this point, there is always a Content-Type field in Header and mt is a
            % nonempty MediaType. Get the explicit or default charset from the MediaType.
            [~, ctfCharset] = matlab.net.internal.getCharsetForMediaType(mt);
            % remember whether ctfCharset is the default
            usesDefault = isempty(mt.getParameter('charset'));
            if isempty(obj.RealCharset) || obj.UseDefaultCharset
                % determine conversion charset if none specified in this object
                if usesDefault
                    % no explicit charset in MediaType
                    if isempty(ctfCharset)
                        % no default charset for the MediaType, so derive from data or platform
                        if isempty(obj.Data)
                            obj.RealCharset = feature('DefaultCharacterSet');
                        else
                            obj.RealCharset = matlab.net.internal.getCharsetFromData(obj.Data);
                        end
                    else
                        % we have a default for the MediaType, use it if Data is equal to or a
                        % subset of default; else use the default
                        obj.RealCharset = ctfCharset;
                        if ~isempty(obj.Data)
                            dataCharset = matlab.net.internal.getCharsetFromData(obj.Data);
                            % We know that us-ascii is a subset of all charsets; else use
                            % the default
                            if ~strcmpi(dataCharset, ctfCharset) && ~strcmpi(dataCharset, 'us-ascii')
                                obj.RealCharset = dataCharset;
                            end
                        end
                    end
                else
                    % MediaType has an explicit charset; just use it
                    obj.RealCharset = ctfCharset;
                end
            end
            % If the header field doesn't have an explicit charset, decide whether to add
            % the parameter
            if usesDefault && ...
                (isempty(ctfCharset) || ~strcmpi(ctfCharset, obj.RealCharset))
                % We don't know the default charset for the MediaType or it's different from the
                % one we're using, so add the one we're using. This might add a charset
                % parameter to some random MediaType that doesn't define such a parameter, but
                % we trust that at worst it will be ignored.
                mt = mt.setParameter('charset', obj.RealCharset);
                ctf = ContentTypeField(mt);
                obj.Header = obj.Header.changeFields(ctf);
            end
        end
        
        function start(obj)
        % START Start a new transfer
        %   START(PROVIDER) is an overridden method of ContentProvider that MATLAB calls
        %   to prepare this provider for new transfer.
        % 
        % See also matlab.net.http.io.ContentProvider.start
        
            % Go back to the beginning of the data, but don't clear ConvertedData, in case
            % we have already done the conversion.
            obj.start@matlab.net.http.io.ContentProvider();
            obj.Offset = 1;
            if isempty(obj.RealCharset)
                % if there is no charset, get it from the Content-Type, if any. This case
                % shouldn't occur if our complete() method was called, but a subclass might not
                % have called that method or cleared the value.
                ctf = obj.Header.getValidField('Content-Type');
                if ~isempty(ctf)
                    mt = ctf.convert();
                    obj.RealCharset = matlab.net.internal.getCharsetForMediaType(mt);
                end
            end
        end
        
        function len = expectedContentLength(obj, varargin)
        % expectedContentLength Return length of data
        %   LEN = expectedContentLength(PROVIDER, FORCE) is an overridden method of
        %   ContentProvider that returns the length of the data or [] if the length is
        %   unknown. If FORCE is false or unspecified, this method returns [], because
        %   determining the length of the data requires converting it. If this provider
        %   is not a multipart delegate, this normally results in a chunked message if
        %   it has no Content-Length field. If FORCE is true, this method computes the
        %   length of the converted data and returns that length.
        %
        % See also matlab.net.http.io.ContentProvider.expectedContentLength
            if ~isempty(varargin) && varargin{1}
                % force specified
                if isempty(obj.ConvertedData)
                    obj.ConvertedData = unicode2native(char(obj.Data), obj.RealCharset);
                end
                len = length(obj.ConvertedData);
            else
                len = [];
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
end
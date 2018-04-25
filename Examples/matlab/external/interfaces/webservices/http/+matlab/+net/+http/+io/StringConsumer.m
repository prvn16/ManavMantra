classdef StringConsumer < matlab.net.http.io.ContentConsumer
% StringConsumer ContentConsumer for HTTP payloads containing character data
%    This consumer stores the data, decoded according to the charset based on
%    the Content-Type, in the response body. You may specify this consumer
%    directly when sending a RequestMessage to specify a string conversion for
%    the data with certain parameters. 
%
%    For example, normally MATLAB converts data in a response message, whose
%    Content-Type is "text/plain" into a scalar string, decoded according
%    to the character encoding (charset) specified in the Content-Type field in
%    the message header. Perhaps you are issuing a request to download a text
%    file that you know is encoded with Shift_JIS, but the server does not
%    know that, so it specified no "charset" parameter in the Content-Type. The
%    default for "text/plain" is US-ASCII (or a superset, UTF-8), which is the
%    incorrect conversion. To interpret the contents as Shift_JIS, and to
%    receive it as a character vector instead of a string:
%
%      request = RequestMessage();
%      consumer = StringConsumer('TextType', 'char', 'Charset', 'Shift_JIS');
%      resp = req.send(url, options, consumer);
%      data = resp.Body.Data;  
%
%    StringConsumer methods:
%      StringConsumer - constructor
%
%    StringConsumer properties:
%      Charset        - character set used to convert the data 
%      TextType       - type of data to return, "string" or "char"
%
%    For subclass authors
%    --------------------
%
%    You can create a subclass of StringConsumer to examine character data as
%    it is being received. To do so, override putData and call this superclass'
%    putData to save the converted string in the response, or use the convert
%    method as a utility to convert the string and store your own data in the
%    response.
%
%    You may also want to implement a subclass of this consumer in cases where
%    the charset of the data is specified in the data. For example, for HTML
%    content ("text/html"), the charset is specified in the <meta> tag at the
%    front of the document. By default "text/html" is processed as US-ASCII.
%    Your putData method could examine input as it is being received, look for
%    and parse the <meta> tag, and then change the charset for properly
%    decoding the rest of the document.
%
%    During receipt of data, the string at Response.Body.Data, or the character
%    vector at Response.Body.Data(1:consumer.CurrentLength) (depending on the TextType)
%    contains the data converted so far. Writing:
%
%         extractBefore(Response.Body.Data, consumer.CurrentLength+1)
%
%    will return the current data whether TextType is char or string.
%  
%    StringConsumer methods (overridden from ContentConsumer):
%      initialize     - initialize this consumer for a new message
%      start          - start transfer of data
%      putData        - append next buffer of data to response
%      convert        - convert string to Unicode
%
%    StringConsumer properties (protected, inherited from ContentConsumer):
%      CurrentLength  - current length of the string or character vector in the
%                       Response.Body.Data buffer. If TextType=string and you
%                       are using putData in this class to store your data, this
%                       is the same as strlength(Response.Body.Data).
%
% See also Charset, putData, Response, ContentConsumer, extractBefore

% Copyright 2016-2017 The MathWorks, Inc.

    properties (Dependent)
        % Charset - character set used to convert the data
        %   This value is initially empty. If you leave it empty, this value will be
        %   set when a message is received, based on the specified or default charset in the
        %   Content-Type field of the message. If you want to force conversion using a
        %   different charset, you can do so by specifying a charset in the
        %   StringConsumer constructor, or directly setting this property. Subclasses
        %   may set this property at any time, including in the middle of a message. If
        %   you change this value after calling putData the new value will be applied to
        %   subsequent calls to putData. Existing contents of Response.Body.Data will
        %   not be changed.
        %
        %   When receipt of a response begins, if this property was initially left
        %   empty, MATLAB sets this property to the chosen charset based on the
        %   Content-Type. If you reuse this consumer for a different message a new
        %   charset may be chosen. If you set this property to a nonempty value, MATLAB
        %   never changes it.
        %
        % See also StringConsumer, initialize, Header,
        % matlab.net.http.field.ContentTypeField, putData
        Charset string
    
        % TextType - type of data to return, string or char
        %   The value is from the 'TextType' parameter to the constructor, which is
        %   either "string" or "char". Default is "string". If you change this value
        %   after data is already stored in Response.Body.Data, that data will be
        %   converted to the new type.
        %
        % See also StringConsumer
        TextType string = "string"
    end
    
    properties (Access=private, Transient)
        % Converter - this is a streaming converter object.
        Converter matlab.net.http.io.internal.StreamingUnicodeConverter
        % UseChar - true to return a character vector.
        %   Value derived from TextType. 'TextType' parameter to the constructor.
        UseChar logical = false
    end
    
    properties (Access=private)
        ExpectedLength = 0;
        UseDefaultCharset logical = false
        RealCharset string
        ExplicitCharsetSpecified logical = false % set when Charset property set
    end

    methods 
        function set.Charset(obj, charset)
            if isempty(charset)
                obj.UseDefaultCharset = true;
                obj.setCharset(string.empty);
                obj.ExplicitCharsetSpecified = false;
            else
                obj.UseDefaultCharset = false;
                obj.setCharset(charset);
                obj.ExplicitCharsetSpecified = true;
            end
        end
        
        function charset = get.Charset(obj)
           charset = obj.RealCharset;
        end
        
        function set.TextType(obj, type)
        % This sets AppendFcn and converts existing data if the type has changed
            value = validatestring(type, {'string','char'}, mfilename, 'TextType');
            useChar = strcmpi(value, 'char');
            if useChar ~= obj.UseChar && ~isempty(obj.Response)
                if useChar
                    obj.Response.Body.Data = char(obj.Response.Body.Data);
                else
                    obj.Response.Body.Data = string(obj.Response.Body.Data);
                end
            end
            if useChar
                obj.AppendFcn = function_handle.empty;
            else
                obj.AppendFcn = @(obj,data) obj.appendString(data);
            end
            obj.UseChar = useChar;
        end
        
        function type = get.TextType(obj)
            if obj.UseChar
                type = "char";
            else
                type = "string";
            end
        end
        
        function obj = StringConsumer(varargin)
        % StringConsumer Construct a ContentConsumer that converts input to a string
        %   CONSUMER = StringConsumer() constructs a consumer that converts input to a
        %   scalar string using the character set specified in the Content-Type of the
        %   message.
        %
        %   CONSUMER = StringConsumer(NAME,VALUE) constructs a consumer that converts
        %   input based on NAME,VALUE parameter pairs:
        %
        %        NAME        VALUE                                      Default
        %        -------     -----------                                --------
        %        TextType    'string' to return a scalar string,        'string'
        %                    'char' to return a character vector
        %
        %        Charset     character encoding to use, or 'default'    'default'
        %                    to derive encoding from the Content-Type
        %
        %   You may also set the above properties after constructing this object.
        %
        %   Determining the charset
        %   -----------------------
        %
        %   If you do not specify a Charset, or you specify 'default', this consumer
        %   tries to derive the charset from the ContentType property, which MATLAB sets
        %   based on the Content-Type field in the Response. StringConsumer will know
        %   the charset if the ContentType has an explicit charset parameter, or if it
        %   is one of the types for which MATLAB knows the default charset:
        %      text/*              US-ASCII or UTF-8 depending on subtype
        %      application/*       UTF-8 for subtypes: json, xml, javascript, css, 
        %                          x-www-form-urlencoded; unknown otherwise
        %   This list of known types and subtypes with default charsets may increase in
        %   future releases.
        %
        %   If this consumer cannot determine the charset from the ContentType in the
        %   message, this consumer will reject the message and it will not be converted.
        %   In that case, the ResponseMessage.Body will contain only a uint8 payload. If
        %   you want to convert a message with an unknown charset, set Charset in this
        %   consumer before applying it to a message (or if you are a subclass author,
        %   before calling the initialize method). A good one to use is UTF-8 because
        %   that is a superset of US-ASCII and some other charsets.
        %
        % See also ContentConsumer, TextType, Charset, ResponseMessage, initialize
            if nargin > 0
                ip = inputParser;
                ip.FunctionName = mfilename;
                ip.addParameter('TextType','string');
                ip.addParameter('Charset','default');
                ip.parse(varargin{:});
                if strcmpi(ip.Results.Charset,'default')
                    obj.UseDefaultCharset = true;
                else
                    obj.Charset = ip.Results.Charset;
                    obj.UseDefaultCharset = false;
                end
                obj.TextType = ip.Results.TextType;
            else
                obj.TextType = 'string';
                obj.UseDefaultCharset = true;
            end
        end
        
        function [len, stop] = putData(obj, data)
        % putData Append next buffer of data to response
        %   [LEN, STOP] = putData(CONSUMER, DATA) is an overridden method of
        %   ContentConsumer that uses the current value of the Charset property to
        %   convert DATA to a Unicode string and append the results to
        %   Response.Body.Data. During this process the currently converted string is
        %   at Response.Body.Data. If TextType is 'char', only characters up to
        %   CurrentLength are valid.
        %
        %   If DATA is [], it indicates end of the message. On return,
        %   Response.Body.Data contains the entire converted string or character
        %   vector.
        %
        %   For multibyte encodings such as UTF-8, it is possible that a given buffer of
        %   DATA ends with a partial multibyte character. In that case
        %   Response.Body.Data might be missing that last character, until the next call
        %   to putData completes it.
        %
        %   If you are implementing a subclass of this consumer and want to examine the
        %   raw bytes prior to charset conversion, override this method, examine data,
        %   change the Charset if necessary, and then pass data to this superclass
        %   method for conversion and storage in Response.Body.Data. If you change
        %   Charset after putData has already been called to process previous buffers,
        %   be aware that a partial multibyte character at the end of the previous
        %   buffer that has not yet been converted could be lost. This would not occur
        %   if all characters previously received are single-byte (e.g., US-ASCII or the
        %   ASCII subset of UTF-8).
        %
        %   A more likely scenario is that you want to examine each buffer of data as it
        %   arrives after charset conversion. To do so, override this method as follows
        %   (this works whether TextType is char or string):
        %
        %     function [len, stop] = putData(obj, data)
        %        oldLength = obj.CurrentLength;                
        %        % send raw bytes to StringConsumer for conversion
        %        [len, stop] = obj.putData@matlab.net.http.io.StringConsumer(data);
        %        newData = obj.Response.Body.Data.extractAfter(oldLength);
        %        ...process newData...
        %
        %   Now newData contains the most recently added data, after conversion. Note
        %   that the above pattern still stores the resulting string in
        %   Response.Body.Data. 
        %   
        %   If your subclass wants to stream its own results into the response after
        %   processing the string, use the convert method to convert your data based on
        %   the TextType and Charset in this object. In that case, call this putData
        %   method only at the end of the data, with an empty argument.
        %
        % See also Charset, TextType, Response, convert,
        % matlab.net.http.io.ContentConsumer.putData
        
            len = length(data);
            stop = false;
            % convert to Unicode
            unicodeStr = obj.convert(data);
            if isempty(data) || ~isempty(unicodeStr)
                % Append to response using superclass, which uses AppendFcn
                [~, stop] = obj.putData@matlab.net.http.io.ContentConsumer(unicodeStr);
                if isempty(data) && ~isempty(unicodeStr)
                    % if unicodeStr had leftover chars but data was empty, need to call superclass
                    % one more time with empty data
                    obj.putData@matlab.net.http.io.ContentConsumer(data);
                end
                if ~isempty(data) && ~obj.UseChar
                    obj.CurrentLength = strlength(obj.Response.Body.Data);
                end
            end
        end
     end
    
    methods (Access=protected)
        function ok = initialize(obj, varargin)
        % initialize Initialize this consumer for a new message
        %   OK = initialize(CONSUMER) is an overridden method of ContentConsumer that
        %   MATLAB calls to prepare this consumer for receipt of a message. Returns
        %   true if Response.Status is OK and Charset is not empty, or ContentType is
        %   set to a MediaType with a known or default charset. If you want to use this
        %   consumer to process a message despite these constraints, set Charset after
        %   creating this consumer or write a subclass that overrides this method to set
        %   Charset prior to invoking this method.
        %
        %   See the constructor for the list of known default charsets.
        %
        % See also matlab.net.http.io.ContentConsumer.initialize, Response, ContentType,
        % StringConsumer, matlab.net.http.MediaType
            ok = obj.initialize@matlab.net.http.io.ContentConsumer(varargin{:});
            if (ok)
                if ~obj.ExplicitCharsetSpecified
                    obj.RealCharset = string.empty;
                end
                if isempty(obj.RealCharset) || strlength(obj.RealCharset) == 0 || obj.UseDefaultCharset
                    ct = obj.ContentType;
                    if ~isempty(ct)
                        obj.setCharset(matlab.net.internal.getCharsetForMediaType(ct));
                    end
                    ok = ~isempty(obj.RealCharset) && strlength(obj.RealCharset) ~= 0;
                end
            end
        end
        
        
        function bufsize = start(obj)
        % start Start transfer of data
        %   BUFSIZE = start(CONSUMER) is an abstract method of ContentConsumer that
        %   prepares CONSUMER for receipt of data. Always returns [] to indicate no
        %   particular buffer size is suggested. Default accumulates the converted
        %   string or character vector in Response.Body.Data. If you override this
        %   method, you should call this superclass method as well.
        %
        % See also matlab.net.http.io.ContentConsumer.start
            bufsize = [];
            obj.CurrentLength = 0;
            if ~isempty(obj.Response.Body)
                if obj.UseChar
                    if ~isempty(obj.ExpectedLength)
                        % Preallocate if result is char vector. This could be as big as 4x the actual
                        % length of Data, if every character in the input is a 4-byte character.
                        obj.Response.Body.Data = char(zeros(1,obj.ContentLength));
                    end
                else
                    % preallocation not useful for string
                    obj.Response.Body.Data = "";
                end
            end
            if ~isempty(obj.Converter)
                obj.Converter = obj.Converter.reset();
            end
        end
        
        function str = convert(obj, data)
        % convert Converts data to a string
        %   STR = convert(CONSUMER, DATA) converts a buffer of DATA to a string or
        %   character vector, STR, based on the current values of Charset and TextType.
        %   This has the same behavior as putData, but returns the converted
        %   string instead of storing it in Response.Body.Data. It does not update
        %   CurrentLength.
        %
        %   This is a utility method for the benefit of subclasses that want to
        %   interpret the data as a string, and then process the results and store their
        %   own data in Response.Body.Data. Subclasses that use this method should
        %   not call putData except to pass in empty DATA at the end of the stream to
        %   tell this class that input has ended.
        %
        %   If DATA ends with a partial multibyte character, that partial character will
        %   be saved internally and not returned until the next call to convert that
        %   provides the remainder of the bytes.
        %
        % See also putData, Charset, TextType, Response, CurrentLength
            data = reshape(data,1,[]);   % make row vector
            % If there is a converter, use it; otherwise just return data coerced to a
            % char vector or string
            if ~isempty(obj.Converter)
                [str, obj.Converter] = obj.Converter.convert(data);
            else
                str = char(data);
                if ~obj.UseChar
                    str = string(str);
                end
            end
        end
    end
    
    methods (Access=private)
        function appendString(obj, strData)
        % appendString Append function for new data
        %   appendString(OBJ, STRDATA) is used for the AppendFcn of ContentConsumer when
        %   this consumer's TextType is 'string'. It appends the string STRDATA to
        %   CONSUMER.Response.Body.Data by adding it to the end of the data and
        %   updates CurrentLength to the length of the resulting string.
        %
        % See also AppendFcn, TextType, Response
            if ~isempty(strData) 
                if isempty(obj.Response.Body.Data)
                    % normally set by start, but our subclass might have cleared it
                    obj.Response.Body.Data = "";
                else
                end
                obj.Response.Body.Data = obj.Response.Body.Data + strData;
                obj.CurrentLength = strlength(obj.Response.Body.Data);
            else
                % nothing special to do at end of string
            end
        end
    end 
    
    methods (Hidden, Access=?tHTTPStringConsumer)
        function setConverter(obj, converter)
        % Test hook to set a converter. This function is for internal use only and may
        % disappear in a future release.
            obj.Converter = converter;
        end
    end
    
    methods (Access=private)
        function setCharset(obj, charset)
        % Sets the charset and initializes converter for the charset. Destroys
        % previous converter. No-op if charset hasn't changed.
            if ~isequal(obj.RealCharset, charset)
                obj.RealCharset = lower(charset);
                obj.Converter = getConverter(obj.RealCharset);  
            end
        end
    end
end

function converter = getConverter(charset)
% Returns a converter for the specified charset. 
    converter = matlab.net.http.io.internal.StreamingUnicodeConverter(charset);
end
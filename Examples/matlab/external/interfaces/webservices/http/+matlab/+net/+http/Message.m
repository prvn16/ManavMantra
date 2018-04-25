classdef (Abstract, AllowedSubclasses={?matlab.net.http.RequestMessage, ...
                                       ?matlab.net.http.ResponseMessage}) Message < ...
                                       matlab.mixin.Heterogeneous
% Message Abstract base class of HTTP messages
%
%   Message properties:
%
%     StartLine - the start line
%     Header    - header of the message
%     Body      - body of the message
%     Completed - true if message is completed
%
%   Message methods:
%
%     getFields     - return header fields
%     addFields     - add header fields
%     changeFields  - change existing header fields
%     removeFields  - remove header fields
%     replaceFields - repalce header fields
%     string        - return the contents of the message as a string
%     char          - return the contents of the message as a character vector
%     show          - return the message as a string with optional maximum length
%
% See also matlab.net.http.RequestMessage, matlab.net.http.ResponseMessage

% Copyright 2015-2017 The MathWorks, Inc.   

    properties
        % StartLine - start line of the message, a matlab.net.http.StartLine
        StartLine % It's really a matlab.net.http.StartLine but we can't declare an abstract type w/o initializing it
        % Header - header of the message, vector of matlab.net.http.HeaderField
        %   When you set this property, the fields of the Header will be checked to
        %   insure that they are appropriate for the type of message. 
        %
        %   In a call to RequestMessage.send, MATLAB adds fields to this Header that are
        %   needed for the type if message being sent, unless you override or suppress
        %   them. A ContentProvider, if specified in Body, may also add or modify
        %   fields. For more information, see the help to RequestMessage.send.
        %
        % See also HeaderField, RequestMessage.send, Body,
        % matlab.net.http.io.ContentProvider
        Header matlab.net.http.HeaderField
        % Body - body of the message
        %   In a RequestMessage, the Body contains or describes the data to be sent. In
        %   a ResponseMessage, the Body contains the response data. In either a
        %   RequestMessage or ResponseMessage, you may set this property to a
        %   MessageBody or any value acceptable to the MessageBody constructor. If this
        %   message has a Content-Type header field, Body.ContentType will be set to the
        %   MediaType in that field, overriding any previous value that have might been
        %   set in that property. Otherwise Body.ContentType will be unchanged.
        %
        %   In a RequestMessage, you may also set this to a ContentProvider that is to
        %   provide the payload of the message.
        %
        % See also RequestMessage, ResponseMessage, MessageBody,
        % matlab.net.http.field.ContentTypeField, matlab.net.http.io.ContentProvider
        Body 
    end
    
    properties (Transient)
        % Completed - true if this message was completed
        %   This property means that the message contains all the headers sent or
        %   received, and if there is a payload, the raw payload as well as possibly
        %   converted data in Body.
        %
        %   In a RequestMessage, methods that validate this message, such as
        %   RequestMessage.send and RequestMessage.complete, set this property to true
        %   once determining that the message is valid and completing any processing
        %   such as adding required header fields and converting Body.Data to
        %   Body.Payload. If you set this to true prior to issuing send or complete,
        %   these methods will not modify message headers, and the send method will
        %   send the message without checking it for validity. Any change to a
        %   property in a message resets this property back to false.
        %
        %   In a ResponseMessage, this property is true if the message contains no
        %   payload (Body or Body.Data are empty), or if Body.Payload contains the raw
        %   data. 
        %
        %   Set this to true in a RequestMessage if you want to prevent the send
        %   method from modifying the headers of the message, thereby letting you send
        %   arbitrary headers. You can still use the complete method to
        %   validate the message, but the send method will attempt to send it whether
        %   or not it is valid. Even if Completed is set, the send method will fill
        %   in any properties of the RequestLine that are empty, and may convert
        %   Body.Data, but it will not reject the message due to invalid headers.
        %
        %   If Body.Payload contains data and Completed is true, RequestMessage.send
        %   will send the payload as is, without attempting to convert any information
        %   in Body.Data. But if Body.Data is nonempty and Body.Payload is empty,
        %   RequestMessage.send will always convert the data based on the content type
        %   (obtained from the Content-Type header field or derived from the type of
        %   Data), regardless of the value of Completed, as it needs to do so to send
        %   the message.
        %
        %   The Completed property set in a RequestMessage or ResponseMessage returned
        %   by RequestMessage.send, or in the HISTORY returned by send, indicates that
        %   the message contains exactly what was sent to or received from the server.
        %   For messages containing a body, this includes the raw data in
        %   Body.Payload. This raw data is not preserved in ReponseMessages unless
        %   you set HTTPOptions.SavePayload or there was an error trying to convert the
        %   payload, so ResponseMessages with a body will not normally have Completed
        %   set.
        %
        % See also matlab.net.http.RequestMessage.send,
        % matlab.net.http.RequestMessage.complete, Body, MessageBody,
        % matlab.net.http.HTTPOptions.SavePayload, ResponseMessage
        Completed logical = false
    end
    
    methods
        function obj = set.Header(obj, value)
            if ~isempty(value) 
                validateattributes(value, {'matlab.net.http.HeaderField'}, ...
                                   {'vector'}, mfilename, 'Header');
                badField = obj.getInvalidFields(value);
                if isempty(badField)
                    obj.Header = value;
                else
                    if isempty(badField.Value)
                        error(message('MATLAB:http:BadFieldNameInHeader', ...
                            char(badField.Name), class(obj)));
                    else
                        error(message('MATLAB:http:BadFieldValueInHeader', ...
                            char(badField.Name), char(badField.Value), class(obj)));
                    end
                end
                obj.checkHeader(value);
            end
            obj.Header = value;
            obj.Completed = false; %#ok<MCSUP> because Completed transient
            if obj.shouldSetBodyContentType() 
                % copy the ContentType header field into the body, if there is one
                ct = obj.getBodyContentType();
                if ~isempty(ct)
                    % note this does not call the set.Body method
                    obj.Body.ContentType = ct; %#ok<MCSUP> because ContentType transient
                end
            end
        end
        
        function obj = set.Body(obj, value)
            if isempty(value) && isnumeric(value)
                obj.Body = matlab.net.http.MessageBody.empty;
            elseif isa(value, 'matlab.net.http.io.ContentProvider') 
                obj.Body = value;
            else
                obj.Body = obj.checkBody(value);
                if obj.shouldSetBodyContentType()
                    % copy the ContentType header field into the body, if there is one
                    ct = obj.getBodyContentType();
                    if ~isempty(ct)
                        obj.Body.ContentType = ct;
                    end
                end
            end
            obj.Completed = false; %#ok<MCSUP> because Completed transient
        end
        
        function obj = set.StartLine(obj, value)
            if ~isempty(value) || ~isnumeric(value)
                validateattributes(value, {obj.getStartLineType() ...
                                    'matlab.net.http.StartLine'}, {'scalar'}, mfilename, 'StartLine');
            end
            obj.StartLine = value;
            obj.Completed = false; %#ok<MCSUP> because Completed transient
        end
        
        function obj = set.Completed(obj, value)
            validateattributes(value, {'logical'}, {'scalar'}, mfilename, 'Completed');
            obj.Completed = value;
        end
    end
    
    methods (Access=protected)
        function obj = Message()
            obj.Body = matlab.net.http.MessageBody.empty;
        end
    end
    
    methods (Sealed)
        % These methods are sealed so they can be called on a heterogeneous array
        
        function [fields, indices] = getFields(obj, varargin)
        % getFields Return fields from HTTP message headers
        %   [FIELDS, INDICES] = getFields(MESSAGES, IDS) returns FIELDS, a vector of
        %     HeaderField in the vector of MESSAGES that match the IDS, and a vector
        %     of their INDICES. The IDS can be:
        %       - a character vector, vector of strings, comma-separated list of
        %         strings or character vectors, or cell array of character vectors
        %         naming the fields to be returned. Names are not case-sensitive.
        %       - a vector of HeaderField or comma separated list of them, whose names 
        %         are used to determine which fields to return. Names are not
        %         case-sensitive and Values of the HeaderFields are ignored.
        %       - a vector of meta.class that are subclasses of HeaderField, or 
        %         comma-separated list of them. For each class, this matches any
        %         fields that are instances of that class (including its subclasses)
        %         plus any fields whose names match the names explicitly supported by
        %         the class or its subclasses.
        %
        %         For example MediaRangeField has two subclasses, AcceptField and
        %         ContentTypeField. If you specify an ID of
        %         ?matlab.net.http.field.MediaRangeField it will match all fields of
        %         of class MediaRangeField, AcceptField and ContentTypeField, plus any
        %         fields with the Name 'Accept' or 'Content-Type' (such as
        %         matlab.net.http.HeaderField or matlab.net.http.field.GenericField).
        %
        %     If MESSAGES contains more then one message, INDICES is a cell array of
        %     vectors, where INDICES{i} contains the indices of the matching fields
        %     in MESSAGE(i).
        %
        %     If there is no match, Fields is HeaderField.empty.
        %
        %     Header field name matching is case-insensitive.
        %
        %     If there is more than one match, FIELDS is a vector containing all the
        %     matches. If they are all the same type, it is generally possible to
        %     call convert(FIELDS) to obtain a vector of their converted values.
        %     Except for the Set-Cookie field, multiple fields of the same type are
        %     allowed in a message only if the field syntax supports a comma-separated
        %     list of values.
        %
        % See also HeaderField, Header, removeFields, addFields, changeFields, meta.class,
        % matlab.net.http.HeaderField.convert, matlab.net.http.field.SetCookieField,
        % matlab.net.http.field.MediaRangeField, matlab.net.http.field.AcceptField,
        % matlab.net.http.field.ContentTypeField
            fields = matlab.net.http.HeaderField.empty;
            if isempty(varargin)
                error(message('MATLAB:minrhs'));
            end
            if nargout > 1
                if ~isscalar(obj)
                    indices{length(obj)} = [];
                else
                    indices = [];
                end
            end
            for i = 1 : length(obj)
                msg = obj(i);
                if ~isempty(msg.Header)
                    if nargout > 1
                        if iscell(indices)
                            [flds, indices{i}] = msg.Header.getFields(varargin{:});
                        else
                            [flds, indices] = msg.Header.getFields(varargin{:});
                        end
                    else
                        flds = msg.Header.getFields(varargin{:});
                    end
                    fields = [fields flds]; %#ok<AGROW>
                end
            end
        end
        
        function obj = addFields(obj, varargin)
        % addFields Add fields to an HTTP message header
        %   MESSAGES = addFields(MESSAGES,FIELDS) returns a copy of the message array 
        %     MESSAGES with additional fields added to the end of the header of each
        %     message. FIELDS is a vector of HeaderField objects or comma separated list
        %     of them. There is no check for duplicate fields, but RequestMessage.send
        %     and RequestMessage.complete may reject inappropriate duplicates.
        %
        %   MESSAGES = addFields(MESSAGES,NAME1,VALUE1,...,NAMEn,VALUEn) adds fields 
        %     with NAME and VALUE to end of Header of each message. A VALUE may be ''
        %     to use the default value for the field (usually, but not necessarily, []).
        %     If the last VALUE is missing, it is the same as specifying [] (see below).
        %     The type of HeaderField object created depends on its NAME, and any VALUEs
        %     are validated for that type.
        %
        %   MESSAGES = addFields(MESSAGES,INDEX,___) inserts fields at the specified 
        %     INDEX in Header. Can be used in combination with any of above. Adds to
        %     end if INDEX is greater than length of Header. If INDEX is negative,
        %     counts from end of header, where 0 adds fields to the end and -1 inserts
        %     fields before the last field.
        %
        %   If the value of any header field is [], this indicates that the field
        %   should not be automatically added when the message is sent or completed.
        %   In a message already completed, a value of [] does not remove instances
        %   of that field already present in the message. Fields with empty values
        %   are remvoed from the message prior to sending.
        %
        % See also HeaderField, Header, RequestMessage, getFields, changeFields, replaceFields,
        % removeFields, Completed, complete
        
        % Undocumented behavior for internal use only -- this may change in a future
        % release:
        %   addFields(STRUCTS) - array of structures containing Name and Value
        %     fields.
            obj = obj.addFieldsPrivate(true, varargin{:});
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'addFields');
        end
        
        function obj = changeFields(obj, varargin)
        % changeFields Change existing fields in an HTTP message header
        %   MESSAGES = changeFields(MESSAGES,NAME1,VALUE1,...,NAMEn,VALUEn) returns a 
        %     copy of the message array MESSAGES with changes to the values of existing
        %     fields in each message. NAME is the name of the field and VALUE is the
        %     new value. Specify a VALUE of '' to reset a field to its default value, or
        %     [] to prevent the field from being automatically added when the message is
        %     completed (e.g., by RequestMessage.send or RequestMessaget.complete). The
        %     last VALUE, if missing, is assumed to be [].
        %
        %     NAME matching is case-insensitive; however if the NAME you specify
        %     differs in case from the existing name, then the field's name will be
        %     changed to NAME. This usage will never change the class of an existing
        %     field in MESSAGES.
        %     
        %   MESSAGES = changeFields(MESSAGES,NEWFIELDS) changes existing FIELDS to the 
        %     names, values and types in NEWFIELDS, a vector of HeaderFields or
        %     comma-separated list of them. Matching is by case-insensitive Name. This
        %     may change the class of an existing field if its Name is a
        %     case-insensitive match to the Name in NEWFIELDS.
        %
        %  This method is designed to modify existing fields. It throws an error if all
        %  the specified fields are not already in the header of each message, or if
        %  there is more than one match to a specified field.
        %
        % See also HeaderField, Header, addFields, getFields, removeFields, replaceFields
        % matlab.net.http.RequestMessage.send, matlab.net.http.RequestMessage.complete

            % Make array of generic HeaderField objects out of args and validate proposed
            % values.
            [fields, useClasses] = matlab.net.http.HeaderField.getInputsAsFields(false, false, varargin{:});
            for midx = 1 : length(obj)
                obj(midx).checkHeader(fields);  % validate fields are appropriate
                % Now merge them in. This errors if field isn't already in.
                obj(midx).Header = obj(midx).Header.changeFieldsInternal(fields, useClasses, false);
            end
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'changeFields');
        end
        
        function obj = removeFields(obj, varargin)
        % removeFields Remove fields from an HTTP message header
        %   MESSAGES = removeFields(MESSAGES, IDS) returns a copy of the message array
        %   MESSAGES with all header fields matching IDS removed. The IDS can be:
        %     - a character vector, vector of strings, comma-separated list of
        %       strings or character vectors, or cell array of character vectors
        %       naming the fields to be removed. Names are not case-sensitive.
        %     - a vector of HeaderField or comma-separated list of them, whose names 
        %       are used to determine which fields to remove. Names are not
        %       case-sensitive and Values and classes of the HeaderFields are ignored.
        %     - a vector of meta.class that are subclasses of HeaderField, or
        %       comma-separated list of them. For each class, this matches any fields
        %       that are instances of that class (including its subclasses) plus any
        %       fields whose names match the names explicitly supported by the class
        %       or its subclasses.
        %
        %   For example MediaRangeField has two subclasses, AcceptField and
        %   ContentTypeField. If you specify an ID of
        %   ?matlab.net.http.field.MediaRangeField it will match all fields of
        %   class MediaRangeField, AcceptField and ContentTypeField, plus any fields
        %   with the Name 'Accept' or 'Content-Type' (such as
        %   matlab.net.http.HeaderField or matlab.net.http.field.GenericField).
        %
        % See also HeaderField, Header, addFields, changeFields, getFields, replaceFields
        
            [names, classes] = matlab.net.http.HeaderField.getNamesAndClasses(varargin);
            for midx = 1 : length(obj)
                obj(midx).Header = obj(midx).Header.removeFieldsInternal(names, classes);
            end
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'removeFields');
        end
        
        function obj = replaceFields(obj, varargin)
        % replaceFields changes values in or adds fields to an HTTP message header
        %   MESSAGES = replaceFields(MESSAGES,NAME1,VALUE1,...,NAMEn,VALUEn)
        %   MESSAGES = replaceFields(MESSAGES,NEWFIELDS)
        %   This method is the same as changeFields, but if a field does not already
        %   exist which matches the name or class, adds a new one to the end of Header
        %   instead of throwing an error.
        %
        % See also HeaderField, Header, addFields, removeFields, getFields, changeFields
        
            [fields, useClasses] = matlab.net.http.HeaderField.getInputsAsFields(false, false, varargin{:});
            for midx = 1 : length(obj)
                obj(midx).checkHeader(fields);  % validate fields are appropriate
                % no error if field not in
                obj(midx).Header = obj(midx).Header.changeFieldsInternal(fields, useClasses, true);
            end
            matlab.net.http.internal.nargoutWarning(nargout,mfilename,'replaceFields');
        end
        
        function res = char(obj)
        % CHAR Return an HTTP message as a character vector
        %   CHR = CHAR(MESSAGES) converts the message MESSAGES to a character vector.
        %   If MESSAGES is an array with more than one message, returns a cell array of
        %   character vectors.
        %
        %  For more information, see string.
        %
        % See also string, show
            num = length(obj);
            if num > 1
                res = cell(1,num);
            end
            for i = 1 : num
                field = obj(i);
                sHeader = sprintf('%s\n', char(field.Header));
                if isempty(field.Body) || ...
                        (isempty(field.Body.Data) && isempty(field.Body.Payload))
                    str = sprintf('%s\n%s', char(field.StartLine), sHeader);
                else
                    str = sprintf('%s\n%s%s\n', char(field.StartLine), ...
                                  sHeader, field.Body.char());
                end
                if num > 1
                    res{i} = str;
                else
                    res = str;
                end
            end
        end
        
        function str = string(obj)
        % STRING Return an HTTP Message as a string
        %   STR = STRING(MESSAGES) returns the array of MESSAGES, including StartLine,
        %   Header and Body, as an array of strings. The string is an approximate
        %   representation of what the message would look like when sent or received.
        %   If the Body contains binary data (as opposed to character data) a single
        %   line appears indicating the length of the data.
        %
        %   This method is intended for logging or debugging.
        %
        % See also show, char
            str = string(obj.char());
        end
        
        function str = show(obj, varargin)
        % SHOW Display or return a human-readable version of a message
        %   SHOW(MESSAGES) displays whole messages, including Header and Body, in the
        %   command window. If MESSAGES is an array with more than one message,
        %   displays all of the messages with dashed lines separating the messages.
        %
        %   SHOW(MESSAGES, MAXLENGTH) displays at most MAXLENGTH characters of the Body.
        %   If the body is longer than this, displays an indication of the total
        %   length of the data in characters and the type of the data.
        %
        %   STR = SHOW(___) returns a string containing the information that would be
        %   displayed.
        %  
        %   If the Body contains binary data that cannot be converted to characters,
        %   SHOW displays or returns a single line for the Body, indicating the
        %   length of the data in bytes.
        %
        %   This method is intended for diagnostics or debugging.
        %
        % See also string, char, Body
            num = length(obj);
            if nargout > 0
                str(num) = "";
            end
            for i = 1 : length(obj)
                msg = obj(i);
                if ~isempty(msg.Header)
                    sHeader = sprintf('%s\n', string(msg.Header));
                else
                    sHeader = '';
                end
                if i > 1 && nargout == 0
                    fprintf('------------------------------------------\n');
                end
                % If the Body has no show method, or if it's empty or a MessageBody with empty
                % Data and Payload, don't show its contents
                if isempty(msg.StartLine)
                    startLineString = '';
                else
                    startLineString = sprintf("%s\n", string(msg.StartLine));
                end
                if isempty(msg.Body) || ~ismethod(msg.Body, 'show') || ...
                        (isa(msg.Body, 'matlab.net.http.MessageBody') && ...
                         isempty(msg.Body.Data) && isempty(msg.Body.Payload))
                    if nargout == 0
                        fprintf('%s%s', startLineString, sHeader);
                    else
                        str(i) = sprintf('%s%s', startLineString, sHeader);
                    end
                else
                    if isa(msg.Body,'matlab.net.http.MessageBody') 
                        % Hack for multipart messages: Normally we display the converted Data, if any,
                        % not the raw Payload. But if there's just one Body part and this is a
                        % multipart message, the Content-Type of the Body will be that of the part. But
                        % if both Payload and Data are set, the Payload should have the raw bytes of all
                        % the parts, which the user would likely rather see for debugging purposes, not
                        % the converted Data, so insert the multipart type into the Body's ContentType.
                        % This will cause MessageBody.show to print the Payload as multipart. In the
                        % process of printing the parts, it will display any parts that are
                        % character-based.
                        ctf = obj(i).Header.getValidField('Content-Type');
                        if ~isempty(ctf)
                            msgType = ctf.convert();
                            if strcmpi(msgType.Type, 'multipart') && ...
                                ~isempty(msg.Body.Payload) && ~isempty(msg.Body.Data)
                                msg.Body.ContentType = msgType;
                            end
                        end
                    end
                    if nargout == 0
                        fprintf('%s%s\n%s\n', startLineString, ...
                                  sHeader, msg.Body.show(varargin{:}));
                    else
                        str(i) = sprintf('%s%s\n%s\n', startLineString, ...
                                  sHeader, msg.Body.show(varargin{:}));
                    end
                end
            end
        end
    end
    
    methods (Access=?matlab.net.http.internal.HTTPConnector, Hidden)
        function obj = setBodyExternal(obj, data)
        % Calls the setBody method from other classes
            obj = setBody(obj, data);
        end
    end
        
    methods (Abstract, Static, Access=protected, Hidden)
        % checkHeader(header) - throw error if the header has any invalid fields
        %   for this message type. Invoked from set.Header after verifying its type.
        checkHeader(header)
        
        % body = checkBody(value) - throw error if the value is not suitable for the body
        %   of this message type and return the input, possibly converted. Invoked from
        %   set.Body for all nonempty values.
        body = checkBody(value)
        
        % getStartLineType - get the specific type of the StartLine for this message.
        %   Returns a string.
        type = getStartLineType()
        
        % getInvalidFields Check whether the fields are valid for this header
        %   This function is intended to be implemented by subclasses to place
        %   restrictions on fields that are not allowed for the subclass. It is
        %   invoked by the set method of the Fields property after verifying that the
        %   fields value is a vector of matlab.net.http.HeaderField. If an invalid
        %   field is found, it returns the invalid field, and the infrastructure will
        %   print the appropriate error message. If the problem is only with the
        %   field's Name, the subclass should set the Value in the returned field to
        %   [] in order to produce the appropriate message.
        badField = getInvalidFields(fields) 
        
        % Return true if setting the ContentType header field in this message should
        % also set the ContentType in the Body. 
        tf = shouldSetBodyContentType()
    end
    
    methods (Access=protected, Hidden)
        function res = getSingleField(obj, name)
        % getSingleField returns one header field
        %   FIELD = getSingleField(obj, NAME) returns the HeaderField matching NAME.
        %   Use this method to extract a field that you only expect to appear once in
        %   a message header. If there is more than one instance of the field, this
        %   errors out. If the field does not appear in the header, this returns [].
        %    
        %   See also getAllFields
            res = obj.getFields(name);
            if ~isempty(res) && length(res) > 1
                error(message('MATLAB:http:MoreThanOneField', name));
            end
        end
    end       

    methods (Access=?matlab.net.http.RequestMessage, Sealed)
       function obj = addFieldsPrivate(obj, check, varargin)
        % Add fields to the header, with optional check of validity
        %   obj - a message array
        %   check - if true, any errors thrown by subclass constructors of HeaderField 
        %      will be thrown from this function. If false, a Generic HeaderField
        %      object will be created if the subclass constructor fails. 
        %   varargin - an optional INDEX plus an array of HeaderField, an array of
        %      structs containing Name/Value fields, or a list of name/value pairs.
            import matlab.net.http.HeaderField;
            [fields, where] = HeaderField.getInputsAsFields(check, true, varargin{:});
            for midx = 1 : length(obj)
                obj(midx).Header = obj(midx).Header.addFieldsInternal(where, fields);
            end
       end
    end

    
    methods (Sealed, Access=protected, Hidden)
        function obj = addFieldsSilent(obj, varargin)
        % addFieldsSilent Add fields without throwing an error
        %   Same as addFields but silently creates a
        %   matlab.net.http.field.GenericField header field if the Value of a field
        %   is inappropriate for its Name.
        %
        %   varargin - an array of matlab.net.http.HeaderField, an array of structs
        %      containing Name/Value fields, or a list of name/value pairs.
        %
        %   See also matlab.net.http.HeaderField, addFields
            obj = obj.addFieldsPrivate(false, varargin{:});
        end
        
        function ct = getBodyContentType(obj, body)
        % If this message contains a MessageBody object, or a 2nd parameter containing a
        % body is provided, return the MediaType in the Content-Type header field. If
        % not, return [].
            ct = [];
            if (~isempty(obj.Body) || (nargin > 1 && ~isempty(body))) && ...
                    isa(obj.Body, 'matlab.net.http.MessageBody')
                ctf = obj.getSingleField('Content-Type');
                ct = obj.getMediaTypeFromContentType(ctf);
            end
        end
        
        function mediaType = getMediaTypeFromContentType(~, contentTypeField)
        % Get a MediaType object from the contentTypeField. If it doesn't parse as a
        % Content-Type field:
        %   If it's a GenericField, we want to silently accept, so return
        %   MediaType('text/plain'). If it's a ContentTypeField, we throw the conversion
        %   error. This shouldn't be possible, but just in case.
            if isempty(contentTypeField) || isempty(contentTypeField.Value)
                mediaType = matlab.net.http.MediaType.empty;
            else
                try
                    mediaType = contentTypeField.convertLike('Content-Type');
                catch e
                    if isa(contentTypeField, 'matlab.net.http.field.GenericField')
                        mediaType = matlab.net.http.MediaType('text/plain');
                    else
                        rethrow(e);
                    end
                end
            end
        end
    end
    
    methods (Access={?matlab.net.http.RequestMessage, ...
                     ?matlab.internal.webservices.HTTPConnector, ...
                     ?matlab.net.http.internal.HTTPConnector})
        function obj = addFieldsNoCheck(obj, varargin)
        % addFieldsSilent Add fields to end of header without checking for errors
        %   This function is the same as addFields, except that it does not enforce
        %   any constraints on the names of the fields or their values. If a
        %   subclass of HeaderField with the specified NAME cannot be constructed due
        %   to an invalid VALUE, it constructs a generic HeaderField object.
        %
        % See also matlab.net.http.Header.addFields, matlab.net.http.HeaderField
            obj = obj.addFieldsSilent(varargin{:});
        end
    end
    
    methods
        function tf = isequal(this,other)
        % ISEQUAL Compare two messages 
        %   TF = ISEQUAL(M1,M2) returns true if the visible public properties of all 
        %   the messages in the two Message arrays are equal.
            tf = length(this) == length(other) && strcmp(class(this),class(other));
            if tf
                tf = all(arrayfun(@(this,other) ...
                         isequal(this.StartLine, other.StartLine) && ...
                         isequal(this.Header, other.Header) && ...
                         isequal(this.Body, other.Body) && ...
                         isequal(this.Completed, other.Completed), this, other));
            end
        end
    end
end



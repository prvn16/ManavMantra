classdef (Sealed) MessageBody 
    %MessageBody The payload of an HTTP message
    %   This object is contained in the Body property of a RequestMessage or
    %   ResponseMessage.
    %
    %   MessageBody properties:
    %
    %     Data          - the data prior to conversion to or after conversion from 
    %                     a byte stream
    %     ContentType   - (read-only) the content type, if known
    %     ContentCoding - (read-only) content-coding of the payload
    %     Payload       - the raw byte stream, if set or saved
    %
    %   MessageBody methods:
    %
    %     MessageBody  - constructor
    %     string, char - return the data as a string or character vector
    %     show         - return the data as a string with optional maximum length
    %
    %   If you want to send a RequestMessage that contains data (which is usually a
    %   PUT or POST request), you can set the Body property to your data or to a
    %   MessageBody object containing your data. By default the data you specify
    %   goes into the MessageBody.Data property. When you send a message containing
    %   this data, MATLAB converts the data to a uint8 vector that is the payload of
    %   the message sent to the server. Conversion of MATLAB data to a payload
    %   depends on the type of the data and the Content-Type header field you
    %   specify in the message (e.g., using a ContentTypeField). If you do not
    %   specify a content type, MATLAB heuristically tries to deduce the content
    %   type and creates a ContentTypeField naming that type. These conversions are
    %   described for the Data property below.
    %
    %   If you want to send a uint8 vector without any conversion, regardless
    %   of the value of the ContentTypeField, set Payload instead of Data.
    %
    %   As an alternative to using a MessageBody that contains data, you can use one
    %   of the provided ContentProviders to convert and send your data. Place the
    %   desired ContentProvider object into RequestMessage.Body instead of a
    %   MessageBody object. Often this gives you more control over conversion of
    %   the data and provides a streaming benefit. In addition there are
    %   ContentProviders that create additional types of content, such as multipart
    %   messages.
    %
    %   In a ResponseMessage that contains a payload, the Body.Data property
    %   contains the payload, converted to MATLAB data, based on the Content-Type
    %   specified by the server in the response message. These conversions are
    %   described for the Data property below.
    %
    %   Normally, either the Data or Payload is set, but not both. If you
    %   explicitly set one, the other is cleared, and requests and responses have
    %   only Data set. But if you specify HTTPOptions.SavePayload, messages
    %   returned by RequestMessage.send, as well as messages stored in the
    %   returned LogRecords, will have both Data and Payload set, where Payload
    %   represents the uint8 vector sent to or received from the server, and Data
    %   is the MATLAB data.
    %
    %   Also, both Data and Payload may both be set in the message returned by
    %   RequestMessage.complete, and in HTTPException.Request when there was an
    %   exception communicating with the server or converting the data.
    %
    %   See also RequestMessage.Body, RequestMessage.send,
    %   RequestMessage.complete, ResponseMessage, HTTPOptions, LogRecord,
    %   matlab.net.http.io.ContentProvider
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Dependent)
        % Data - The payload of the message in the form of MATLAB data 
        %   In a RequestMessage, this is the MATLAB data prior to any conversion to a
        %   uint8 payload, and in a ResponseMessage, this is MATLAB data after
        %   conversion from a uint8 payload. Data may be of multiple types.
        %
        %   In a RequestMessage, conversion of Data to a payload depends happens when
        %   you call RequestMessage.send or RequestMessage.complete. This conversion
        %   depends on the Content-Type you specify in the message and the type of
        %   Data. If you do not specify a Content-Type, the send and complete methods
        %   try to deduce the type from the data and add the appropriate
        %   ContentTypeField to the RequestMessage. 
        %
        %   In a ResponseMessage, the Data represents the payload converted to a MATLAB
        %   type based on the Content-Type specified by the server in the
        %   ResponseMessage. If the response message is a multipart message created by
        %   a MultipartConsumer, the Data may be a vector of ResponseMessages, one for
        %   each part, where each part contains the header of the part and the body
        %   contains the data for that part.
        %
        %   Output Conversion for RequestMessage
        %   ------------------------------------
        %
        %   The following explains how Data is converted to a payload in a
        %   RequestMessage based on the type/subtype and charset that you specify in
        %   the ContentTypeField. In this description * means any subtype.
        %
        %   Alternatively, instead of specifying a ContentTypeField and inserting your
        %   data into MessageBody.Data, you can provide your data to one of the
        %   ContentProviders designed for the type of data you want to send, and insert
        %   the ContentProvider into a RequestMessage.Body. Often that gives you more
        %   control over data conversion than using a MessageBody object, provides a
        %   streaming benefit, and lets you send particular types of messages such as
        %   multipart forms.
        %
        %   application/json
        %      Data is converted to a Unicode string using the jsonencode function,
        %      and that string is converted to uint8 based on the charset (default
        %      UTF-8) using unicode2native. If you already have a JSON-encoded string
        %      that you want to send in a message with a Content-Type of
        %      application/json, set the Payload property to the string or character
        %      vector. That string will then be converted to uint8 using the charset
        %      in the ContentTypeField, or by default, UTF-8. See also JSONProvider.
        %
        %   text/* (any subtype other than csv or xml)
        %      If Data is a character or string array or cell array of character
        %      vectors, it will be reshaped and concatenated by row to form a vector.
        %      If data is of any other type, it will be converted to a string using
        %      the string function. The resulting string will be converted to uint8
        %      based on the charset. If you did not specify a charset, the default
        %      depends on the subtype. For these subtypes:
        %           json  jtml  javascript css  calendar
        %      the default is UTF-8. For all other subtypes, MATLAB examines the
        %      string to determine the charset. If all characters are in the ASCII
        %      range, the charset is US-ASCII. Otherwise the charset is UTF-8. Note
        %      that text types encoded as UTF-8, without an explicit charset
        %      that says UTF-8, may not be interpreted properly by servers, so it is
        %      best to specify UTF-8 explicitly if you think that your data is
        %      non-ASCII.
        %
        %      See also StringProvider, which gives you more control over data
        %      conversion.
        %
        %   image/*
        %      Data must be MATLAB image data in any form acceptable as the first
        %      argument to to imwrite (e.g., M-by-N, M-by-N-by-3). Conversion of that
        %      data to uint8 depends on the subtype. The following subtypes are
        %      supported:
        %       
        %        subtype                format used by imwrite
        %        -------                --------------------------
        %        bmp                    bmp
        %        gif                    gif
        %        jpeg                   jpeg
        %        jp2                    jp2
        %        jpx                    jpx
        %        png                    png
        %        tiff                   tiff
        %        x-hdf                  hdf
        %        x-portable-bitmap      pbm
        %        x-pcx                  pcx
        %        x-portable-graymap     pgm
        %        x-portable-anymap      pnm
        %        x-portable-pixmap      ppm
        %        x-cmu-raster           ras
        %        x-xwd                  xwd
        %
        %      If the subtype is any value not in the above list, the subtype will be
        %      passed into imwrite as the format, which may or may not succeed.
        %
        %      You can more finely control conversion of your image data to a payload,
        %      or override the type of conversion based on the subtype above, by
        %      specifying parameters to imwrite, other than the filename, in a cell
        %      array. In this case, if you specify a fmt argument (the image format),
        %      it will override any conversion assumed above. For example:
        %
        %          body = MessageBody({imageData, 'jpg', 'Quality', 50});
        %          req = RequestMessage('put', ContentTypeField('image/jpeg'), body);
        %          resp = req.send(url);
        %
        %       would convert imageData to JPEG with compression quality 50, and
        %       send it with 'image/jpeg' Content-Type to the specified url.
        %
        %       See also ImageProvider, which gives you more explicit control over
        %       conversion.
        %
        %   application/xml
        %   text/xml
        %      If data is an XML DOM in the form of a Java org.w3c.dom.Document object
        %      (such as that returned the xmlread function), it will be converted to a
        %      string using xmlwrite. If it is already a string or character vector,
        %      it will be unchanged. The string will be converted to uint8 using the
        %      specified charset (default UTF-8). 
        %
        %   audio/*
        %      Data must be a cell array of at least two values, an m-by-n matrix of
        %      audio data and a sampling rate in Hz, as described for audiowrite. You
        %      can specify additional parameters to audiowrite by adding additional
        %      arguments to the cell array. The following types are recognized:
        %
        %          audio/x-wav      audio/wav          audio/mp4
        %          audio/vnd.wav    application/ogg    audio/flac 
        %
        %   application/csv
        %   text/csv
        %   application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        %   application/vnd.ms-excel
        %      If data is a table, it is converted using writetable. For the csv
        %      subtypes, it and will be converted to comma-delimited text using the
        %      specified charset (default ASCII). For the other types it will be
        %      converted to Excel spreadsheet data. If you want to specify additional
        %      arguments (Name,Value pairs) to writetable, include the data in a cell
        %      array containing the additional arguments. If these additional
        %      arguments include a 'FileType', that type must be consistent with the
        %      subtype you specify. If data is a string or character vector, it will
        %      be sent unconverted as string using the charset specified in the
        %      content type (default US-ASCII for text/csv and UTF-8 for the others).
        %
        %   applicaton/x-www-form-urlencoded
        %      If data is a vector of matlab.net.QueryParameter, it is converted to a
        %      URL-encoded string. If it is a string or character vector, it is
        %      left unchanged.
        %
        %      See also FormProvider.
        %
        %   If you do not specify a ContentTypeField in the RequestMessage, MATLAB
        %   attempts to guess the type, subtype and charset by examining the Data, and
        %   then processes the Data as above. This guess may not result in the
        %   Content-Type you intended, or may fail to determine the type, so it is
        %   generally best to specify the Content-Type. The following describes the
        %   assumed Content-Type based on the data. Other types not listed below may
        %   be handled as well, but behavior for unlisted types is not guaranteed to
        %   remain the same in future releases.
        %     
        %     string, character array, cell array of character vectors
        %       text/plain
        %
        %     table
        %       text/csv
        %
        %     cell vector whose first element is table
        %       If there is a name,value pair in the vector with the value
        %       'FileType','csv' or there is no such pair, Content-Type is text/csv.
        %       If the FileType says 'spreadsheet' then the Content-Type is
        %       application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.
        %
        %     vector of matlab.net.QueryParameter
        %       application/x-www-form-urlencoded
        %
        %     org.w3c.dom.Document
        %       application/xml
        %
        %   If you have a uint8 vector of bytes to send and do not want any conversion
        %   of the data regardless of what is in the ContentTypeField, set Payload
        %   instead of Data. If you want to send character-based data with no
        %   conversion other than the charset, and you are not specifying a
        %   ContentTypeField with one of the above content types that would process
        %   character data (such as application/json), you can set Data to a string or
        %   character vector. For types that would process character data, set
        %   Payload to that string or character vector.
        %
        %   Input Conversion for ResponseMessage
        %   ------------------------------------
        %
        %   The following is a list of the Content-Types that MATLAB recognizes in a
        %   ResponseMessage based the type/subtype and charset in the received
        %   ContentTypeField. These conversions are done only if
        %   HTTPOptions.ConvertResponse is true (which is the default). A * below
        %   means any characters.
        %
        %   If you server returns a Content-Type that MATLAB does not recognize, or a
        %   Content-Type inconsistent with the type of data, you can force MATLAB to
        %   convert the response using a known Content-Type by modifying the
        %   Content-Type field in the response message after receipt to one of those
        %   described below. See the description of ResponseMessage.complete for more
        %   information.
        %
        %   As an alternative to making use of the automatic conversions described
        %   below, if you know what type of data to expect, you can specify a
        %   ContentConsumer in the call to RequestMessage.send. The consumer will
        %   then convert the data in a manner similar to below, but often gives you more
        %   options for how to convert the data. See th e documentation on the various
        %   ContentConsumers.
        %
        %   application/json
        %     Data is converted to a string based on the charset (default UTF-8) and
        %     then to MATLAB data using jsondecode. See also JSONConsumer.
        %
        %   image/*
        %     Data is converted to an image using imread with the specified subtype as
        %     the format, using default arguments. If imread returns more than one
        %     value (e.g., an indexed image such as a GIF also returns a colormap, and
        %     a PNG image also returns an alpha channel), then Data is a cell array of
        %     those values. The types of image data supported is the same as that
        %     listed above for image/* in a RequestMessage. See also ImageConsumer.
        %
        %   audio/*
        %     Data is converted using audioread to a cell array of two values, an
        %     m-by-n matrix of audio data and a sampling rate in Hz. The subtype
        %     determines the format used by audioread. The types recognized are:
        %
        %        audio/wav  audio/x-wav   audio/vnd.wav   audio/mp4   audio/flac
        %
        %     Note that application/ogg is missing from this list because ogg data
        %     does not necessarily contain audio only.
        %  
        %   text/csv
        %   text/comma-separated-values
        %   application/csv
        %   application/comma-separated-values
        %     Data is converted to table using readtable, with assumed FileType of
        %     csv and charset, if specified, or MATLAB's default encoding.
        %
        %   application/*spreadsheet*
        %     Data is converted to table using readtable, with assumed FileType
        %     spreadsheet.
        %
        %   text/xml
        %   application/xml
        %     If Java is available, data is converted to a Java org.w3c.dom.Document
        %     using xmlread. If Java is not available, data is processed as
        %     text/plain with the UTF-8 charset.
        %
        %   If the type is not one of those listed above, then MATLAB determines
        %   whether it is one of the character-based types:
        %       text/* 
        %       any type mentioning a charset 
        %       application/*javascript
        %       application/x-www-form-urlencoded
        %       application/vnd.wolfram.mathematica.package
        %   MATLAB converts these types to a string, using the charset, if specified,
        %   or US-ASCII for text/plain, UTF-8 for the application types, and MATLAB's
        %   default encoding for the other types. See also StringConsumer.
        %
        %   Incoming Content-Types other than those above may be converted in the
        %   future. If the type is not one of those that MATLAB recognizes, or if
        %   HTTPOptions.ConvertResponse is false, Data will contain the payload
        %   converted to a string if the type is character-based as listed above, or the
        %   raw uint8 vector otherwise.
        %
        %   If MATLAB attempts conversion of incoming data but fails (for example,
        %   image/jpeg data is not valid JPEG data) the History property in the
        %   HTTPException thrown by RequestMessage.send will contain the ResponseMessage
        %   with Payload set to the uint8 payload and, if the type is character-based as
        %   listed above, the Data property is the payload converted to a string.
        %
        %  See also Payload, RequestMessage, ResponseMessage, unicode2native, imwrite,
        %  imread, audiowrite, audioread, matlab.net.http.field.ContentTypeField,
        %  matlab.net.http.HTTPException.History,
        %  matlab.net.http.HTTPOptions.ConvertResponse, jsonencode, jsondecode,
        %  xmlwrite, xmlread, matlab.net.http.io.ContentConsumer,
        %  matlab.net.http.io.MultipartConsumer, matlab.net.http.io.MultipartProvider,
        %  matlab.net.http.io.MultipartFormProvider, matlab.net.http.io.StringProvider,
        %  matlab.net.http.io.StringConsumer, matlab.net.http.io.ImageProvider,
        %  matlab.net.http.io.ImageConsumer, matlab.net.http.io.JSONProvider,
        %  matlab.net.http.io.JSONConsumer, matlab.net.http.io.FormProvider
        Data   % scalar string, vector of char, struct or uint8, anything else
        
        % Payload - the raw bytes as a uint8 vector
        %   In a RequestMessage, you can set this property to a uint8 vector, instead
        %   of Data, if you do not want any output conversion or charset encoding on
        %   the array of bytes. If you set Data instead the data will be converted
        %   based on the ContentTypeField as described for the Data property, and the
        %   COMPLETEDREQUEST returned by RequestMesage.send or RequestMessage.complete
        %   will contain that converted data in the Payload property. In a
        %   ReponseMessage, this property will contain the uint8 vector received from
        %   the server, prior to conversion, if you specified HTTPOptions.SavePayload.
        %
        %   As a convenience, if you store a scalar string or character vector in this
        %   property, it will be converted to a uint8 vector using the charset
        %   specified in or implied by the ContentType property in the MessageBody, if
        %   any, or UTF-8 if none was set. If you desire a different encoding, you
        %   must encode it yourself (using unicode2native, for example) and store the
        %   resulting uint8 vector here. Note that ContentType is not set in a new
        %   MessageBody until the MessageBody is stored in a RequestMessage that
        %   contains a ContentTypeField.
        %
        %   No data types other than uint8 vectors, scalar strings, or character
        %   vectors are permitted here. The result is always a uint8 vector.
        %
        %   When you set this property, Data is cleared. If you send a message where
        %   both Data and Payload are already set, Payload is sent and Data is
        %   ignored. Only ResponseMessages and RequestMessages returned by
        %   RequestMessage.send or RequestMessage.complete can have both properties
        %   set at the same time.
        %
        %   In a ResponseMessage returned by RequestMessage.send, this property is set
        %   to the raw bytes received if you specify a history return argument or
        %   HTTPOptions.SavePayload. It is also set in the ResponseMessage in the
        %   History of an HTTPException if conversion of the payload to MATLAB data
        %   failed.
        %
        % See also Data, RequestMessage, ResponseMessage, LogRecord,
        % matlab.net.http.HTTPOptions.SavePayload, unicode2native, HTTPException
        Payload
    end
    
    properties (Access={?matlab.net.http.internal.HTTPConnector, ...
                        ?matlab.net.http.RequestMessage, ...
                        ?matlab.net.http.ResponseMessage, ...
                        ?matlab.net.http.io.ContentConsumer}, Hidden)
        % The real Payload, uint8 vector. Unlike Payload, Setting this does not
        % change PayloadLength or clear Data.
        PayloadInt
        % The real Data
        DataInt
    end
    properties (GetAccess={?matlab.net.http.ResponseMessage}, ...
                SetAccess={?matlab.net.http.RequestMessage, ...
                           ?matlab.net.http.ResponseMessage, ...
                           ?matlab.net.http.internal.HTTPConnector}, Hidden)
        % The PayloadLength, set each time Payload is set, but not changed when
        % PayloadInt is set. Internal classes can set this to the payload length
        % without actually setting a payload, to indicate the size of the original
        % payload when HTTPOptions.SavePayload was false.
        PayloadLength % uint64 or []
    end
    
    properties (Transient, SetAccess={?matlab.net.http.Message, ...
                                  ?matlab.net.http.RequestMessage, ...
                                  ?matlab.net.http.io.ContentConsumer, ...
                                  ?matlab.net.http.internal.HTTPConnector})
        % ContentType - Content-Type of the data (a MediaType, read-only)
        %   This value is a MediaType with contents identical to what would be
        %   obtained from calling ContentTypeField.convert() on the Content-Type field
        %   in the message containing this MessageBody. This property determines how
        %   contents of the Data property will be or was converted. If the
        %   Content-Type has a MediaType with a charset parameter, or implies a
        %   particular charset, that charset determines the encoding.
        %
        %   You cannot set this property directly. When you create a MessageBody,
        %   this property is initially empty. It is also set to empty any time you
        %   set Data. When you copy a MessageBody into a RequestMessage, or if you
        %   add a Content-Type field to the header, this property will be set to the
        %   value of the ContentTypeField, if there is one. Otherwise it is left
        %   empty. The send and complete methods of RequestMessage then set this
        %   property based on the type of data you store in Data and the value of the
        %   ContentTypeField in the RequestMessage, as described for the Data
        %   property. 
        %
        %   In an incoming message, this is normally the Content-Type in the
        %   ResponseMessage. If Data is present this property indicates what
        %   conversion was done on the payload. If Data is not present (due to a
        %   conversion error or suppressed conversion by setting 
        %   HTTPOptions.ConvertResponse to false) this indicates the conversion that
        %   should be done or was attempted on the payload.
        %
        %   If conversion of the payload required two steps: first charset and then
        %   type/subtype (as is done for application/json or application/xml), but
        %   only the charset conversion was done (due to an unknown type or subtype, a
        %   conversion error, or suppressed conversion because
        %   HTTPOptions.ConvertResponse was false), Data contains the Unicode string
        %   and this property contains only the charset (i.e., Type and Subtype are
        %   empty).
        %
        %   If you set Data, this property is cleared. If you set Payload, this
        %   property is unchanged.
        %
        %   If a ContentConsumer was used to receive a response, the consumer's
        %   ContentType property is copied into this property after the response has
        %   been fully processed.
        %
        % See also Data, Payload, MediaType, RequestMessage, ResponseMessage,
        % matlab.net.http.field.ContentTypeField, matlab.net.http.io.ContentConsumer
        ContentType % MediaType or []
        
        % ContentCoding - Content-Encoding of the payload (read-only)
        %   This property is set to indicate that the Payload of a received message
        %   is encoded. When this is set, no processing was done on the payload and
        %   Data is empty.
        %
        %   If MATLAB receives a message whose payload is encoded using a compression
        %   algorithm that it supports, such as gzip or deflate, it automatically
        %   decodes that payload before attempting any other conversions. If decoding
        %   was successful, it optionally stores the decoded payload in Payload and
        %   the converted payload (if any) in Data. In that case, this property is
        %   empty to indicate that the Payload is not encoded.
        %
        %   If the payload was encoded but decoding was not successful, or you
        %   suppressed decoding by setting HTTPOptions.DecodePayload to false, the
        %   unprocessed still-encoded payload is returned in Payload, Data is left
        %   empty, and this property is set to a vector of strings representing the
        %   value of the Content-Encoding header field in the ResponseMessage. In
        %   this case you can save the Payload as is (e.g., write it to a file), or
        %   process it according to the compression algorithm(s) specified in this
        %   property. For example if the value is 'gzip' you can write the data to a
        %   file and use the gunzip command to process the data.
        ContentCoding string = string.empty
    end
        
    methods
        function obj = MessageBody(data)
        % MessageBody Construct a RequestMessage body
        %   BODY = MessageBody(DATA) constructs a MessageBody object containing DATA.
        %   The DATA, which may be any type of MATLAB data, is stored in the Data
        %   property of this object. Whether this data is able to be transmitted in a
        %   RequestMessage depends on the type of the data and the Content-Type of the
        %   message.
        %
        % See also RequestMessage, Data      
            if nargin > 0
                obj.DataInt = data;
            end
        end
        
        function obj = set.Data(obj, data)
            obj.DataInt = data;
            obj.PayloadInt = []; 
            obj.PayloadLength = [];
            obj.ContentType = [];
        end
        
        function data = get.Data(obj)
            data = obj.DataInt;
        end
        
        function obj = set.Payload(obj, value)
        % Normally this is set to a uint8 by the infrastructure, but we also allow
        % the user to set this to a string, in which case we'll convert it to native
        % using the charset in the ContentType, if any, or utf-8.
            if isempty(value)
                obj.PayloadInt = [];
                obj.PayloadLength = [];
            else
                if (ischar(value) && isvector(value)) || (isstring(value) && isscalar(value))
                    charset = 'utf-8';
                    if ~isempty(obj.ContentType)
                        cs = matlab.net.internal.getCharsetForMediaType(obj.ContentType);
                        if ~isempty(cs)
                            charset = cs;
                        else
                        end
                    else
                    end
                    value = unicode2native(value, charset);
                else
                    validateattributes(value, {'uint8'}, {'vector'}, mfilename, 'Payload');
                end
                obj.PayloadInt = value;
                obj.PayloadLength = length(value);
            end
            obj.DataInt = [];
        end
        
        function value = get.Payload(obj)
            value = obj.PayloadInt;
        end
                
        function str = string(obj)
        % string Return the Data converted to a string
        %   STR = string(BODY) 
        %   This method is intended for display or logging only. It returns the Data
        %   only if it is a scalar string or character vector. If it is anything
        %   else, it returns a short message indicating the length of Payload in bytes
        %   (if set) or the length that the Payload would be if the MessageBody is
        %   sent in a RequestMessage.
        %
        %   If BODY is an array, returns an array of the same size.
        %
        % See also show, Payload, RequestMessage
            str = strings(numel(obj));
            for i = 1 : numel(obj)
                data = obj.DataInt;
                if (ischar(data) && isvector(data)) || (isstring(data) && isscalar(data))
                    % Data is a char vector or string
                    str(i) = string(data);
                else
                    % it's not a string or data not set
                    str(i) = obj.getNonCharString();
                end
            end
            str = reshape(str, size(obj));
        end
        
        function str = char(obj)
        % string Return the Data converted to a character vector
        %   CHR = char(BODY)
        %   For a description see string. If BODY is an array, returns a cell array of
        %   character vectors of the same size.
        %
        % See also string, show
            str = char(obj.string());
        end
        
        function str = show(obj, maxLength)
        % show Display or returns a human-readable version of the data
        %   show(BODY) displays the entire body if it is character data
        %   show(BODY,MAXLENGTH) displays at most MAXLENGTH characters of the data.
        %     If the data is longer than MAXLENGTH, it also displays a line indicating 
        %     the total length in characters. If the ContentType is multipart,
        %     MAXLENGTH applies to each part separately.
        %   STR = show(___) returns the output as a string instead of displaying it.
        %
        %   This method is intended for diagnostics or debugging. It displays or
        %   returns the Data only if is a scalar string or char vector. If it is
        %   anything else, it returns a short message indicating the length of
        %   Payload in bytes (if known) or, if Payload length is not known, the
        %   length that the Payload would be if this BODY were to be sent in a
        %   RequestMessage.
        %
        %   If BODY is an array, assumes it is in a multipart message. In this case it
        %   displays (or returns) information on each member, combined into one string,
        %   separated by part numbers.
        %
        % See also string, char, Payload, RequestMessage
        
            % Multipart notes:
            %   If obj is a scalar, then this is either the body of a message or a multipart
            %   message with just one part. The ContentType of this obj is the type of the
            %   part, not "multipart".
            %
            %   If obj is an array, then each element is a part of the multipart message,
            %   and each part has its own ContentType and ContentCoding. There won't be an
            %   obj that says anything about multipart and any information about additional
            %   multipart headers is lost (though that information might be embedded in the
            %   data of each part in a consumer or provider-specific way). This is normally
            %   the case for response messages.
            %
            %   If obj.ContentType is "multipart" and this obj is a scalar, then the obj contains
            %   the data for the entire message, including headers and boundary delimiters,
            %   in either the Data or Payload, depending on which is set. This is normally
            %   for request messages whose payloads have been saved.
            %
            %   If obj(i).ContentType is "multipart" and obj is an array, then this part
            %   must contain a nested multipart that was not split into separate parts.
            %   (TBD)
            function chars = filter(chars)
                chars = regexprep(chars, '\r\n', '\n');
            end
            haveArgout = nargout ~= 0;
            if haveArgout > 0
                str = "";
            else
            end
            for i = 1 : numel(obj)
                thisObj = obj(i);
                data = thisObj.DataInt;
                if ~ischar(data) && ~isstring(data)
                    % It's not a string or data not set; convert data to string. This
                    % could be extremely long, so it's subject to truncation.
                    if nargin > 1
                        [data, lengthMsg] = thisObj.getNonCharString(maxLength);
                    else
                        [data, lengthMsg] = thisObj.getNonCharString();
                    end
                    if lengthMsg
                        % Not character data; it's just a message about length; so always print it
                        lenMsg = data;
                        len = 0;
                    else
                        % It's the converted data
                        len = strlength(data);
                        if nargin > 1 && len > maxLength
                            lenMsg = thisObj.bodyLengthMessageChars(len);
                        end                        
                    end
                else
                    [data, len] = matlab.net.internal.getSingleStringFromData(data);
                    if nargin > 1 && len > maxLength
                        lenMsg = thisObj.bodyLengthMessageChars(len);
                    end
                end

                isMultipart = ~isempty(thisObj.ContentType) && ~isempty(thisObj.ContentType.Type) && strcmpi(thisObj.ContentType.Type, 'multipart');
                
                if ~isscalar(obj)
                    partMsg = sprintf('-------------PART %d--------------\n', i);
                else
                    partMsg = '';
                end
                if nargin > 1 && ~isMultipart && len > maxLength
                    % Too long, output just the beginning and total length
                    if isstring(data)
                        chars = data.extractBetween(1,maxLength);
                    else
                        chars = data(1:maxLength);
                    end
                    chars = filter(chars);
                    if ~haveArgout
                        fprintf('%s%s\n\n%s\n', partMsg, chars, lenMsg);
                    else
                        str = sprintf('%s%s%s\n\n%s\n', str, partMsg, chars, lenMsg);
                    end
                else
                    data = filter(data);
                    if ~haveArgout
                        fprintf('%s%s\n', partMsg, data);
                    else
                        str = str + partMsg + string(data);
                    end
                end
            end
        end
    end
    
    methods (Access=private)
        function [len, bytes, mediaType] = getLengthBytes(obj)
        % getLength get length and contents of payload
        %   [len, bytes, mediaType] = getLengthBytes(BODY) returns length of payload in bytes
        %   and optionally bytes of the payload. len is the string representation of
        %   the number.
        %     If only len requested:
        %        If PayloadLength is set, return it and its length
        %        If PayloadLength and Payload not set, but Data is set, convert Data
        %        to Payload and return its length in bytes. Return len="unknown" if we
        %        couldn't convert it.
        %     If both len and bytes are requested:
        %        If Payload is set, return its length and bytes.
        %        If Payload not set but Data is set, convert Data to Payload and
        %        return its length and bytes. This may return a length different 
        %        from that in PayloadLength. Return len="unknown" if we couldn't convert it.
        %
        %     To determine the actual number of bytes in a received message prior to
        %     conversion, set HTTPOptions.SavePayload or request history when sending
        %     the message.
            if nargout == 1 && ~isempty(obj.PayloadLength)
                len = num2str(obj.PayloadLength);
            else
                if nargout > 1 || isempty(obj.PayloadLength)
                    try
                        [bytes, mediaType] = obj.getBytes();  % simply returns Payload if set, or converts
                        len = num2str(length(bytes));
                    catch 
                        len = "unknown";
                        if nargout > 1
                            bytes = 0;
                            if nargout > 2
                                mediaType = obj.ContentType;
                            end
                        end
                    end
                else
                    len = num2str(obj.PayloadLength);
                    mediaType = obj.ContentType;
               end
            end
        end
        
        function [bytes, mediaType] = getBytes(obj)
        % getBytes returns the payload as a uint8 array of types
        %   If this is invoked on a MessageBody whose Payload has been set, this
        %   simply returns the Payload. Otherwise this returns the bytes that would
        %   be sent if this MessageBody is used in an outgoing message and there is
        %   no Content-Type specified in the RequestMessage. If you created this
        %   MessageBody for an outgoing message and haven't yet called send or
        %   complete in the RequestMessage, the ContentType will not yet be set and
        %   these bytes will be converted based only on the type of Data, as
        %   described for the Data property. If you set the ContentTypeField of the
        %   RequestMessage and then call complete, the returned RequestMessage will
        %   contain a Body whose ContentType is set to that of the ContentTypeField,
        %   resulting in possibly different conversion.
        %
        %   In an incoming message where Data has already been converted from the
        %   payload based on the incoming ContentType, but Payload has not been set
        %   in this object (for example, because you didn't specify 'SavePayload' in
        %   HTTPOptions), calling this method will give you the bytes that would be
        %   sent if you used this MessageBody, along with its ContentType, in a
        %   RequestMessage. This may not necessarily be the same bytes that were
        %   received, since conversion is not exactly reversible.
        %
        %   mediaType is the type computed based on the ContentType in this object or,
        %   if not specified derived from the type of the data.
        %
        % See also Payload, RequestMessage, ResponseMessage, HTTPOptions.SavePayload
            if ~isempty(obj.PayloadInt)
                % If we have a payload, that's the bytes
                bytes = obj.PayloadInt;
                mediaType = [];
                return;
            end
            
            data = obj.DataInt;
            if isempty(data)
                bytes = [];
                mediaType = [];
                return;
            end
            
            [bytes, mediaType] = matlab.net.http.internal.data2payload(data, obj.ContentType);
        end    
    
        function str = bodyLengthMessageBytes(obj)
         % Return message indicating total length of payload or data in bytes. used when
         % we don't know the ContentType or if it's binary.
            if ~isempty(obj.ContentType)
                if isempty(obj.ContentCoding)
                    mediaType = obj.ContentType.Type + '/' + obj.ContentType.Subtype;
                else
                    mediaType = strjoin(obj.ContentCoding, ', ');
                end
                msg = message('MATLAB:http:BytesOfContentData', obj.getLengthBytes(), mediaType);
            else
                % Get the length in bytes. If there is Data, this is done by converting it.
                % If that conversion returns a media type, display it.
                [len, ~, mt] = obj.getLengthBytes();
                if isempty(mt)
                    msg = message('MATLAB:http:BytesOfData', obj.getLengthBytes());
                else
                    msg = message('MATLAB:http:BytesOfContentData', len, char(mt));
                end
            end
            str = string(msg.getString());
        end

        function str = bodyLengthMessageChars(obj, len)
        % Return message indicating total length of data in characters; obj.DataInt
        % must be a char vector or string
            if nargin < 2
                if ischar(obj.DataInt) 
                    len = length(obj.DataInt);
                else
                    len = strlength(obj.DataInt);
                end
            end
            if ~isempty(obj.ContentType)
                mediaType = obj.ContentType.Type + '/' + obj.ContentType.Subtype;
                charset = matlab.net.internal.getCharsetForMediaType(obj.ContentType);
                if ~isempty(charset)
                    mediaType = mediaType + ' ' + upper(charset);
                else
                end
                msg = message('MATLAB:http:TotalCharsOfContentData', len, mediaType);
            else
                msg = message('MATLAB:http:TotalCharsOfData', len);
            end
            str = string(msg.getString());
        end
        
        function [str, lengthMsg] = getNonCharString(obj, varargin)
        % getNonCharString(maxLength) stringifies non-string data, if possible.
        % Otherwise returns a message about the data's length in bytes. maxLength is
        % optional. Called when type of Data is not string or char (it's [] or some
        % other type). If [] and there is a ContentType that has a charset, convert
        % Payload to string based on charset; otherwise return length message. 
        %
        % lengthMsg == true says str is a message about the data or its length; if false
        % str is the actual data as a string.
        %
        % This method only works for scalar obj
            assert(isscalar(obj));
            if ~isempty(obj.Data) && ~isempty(obj.ContentType)
                charset = matlab.net.internal.getCharsetForMediaType(obj.ContentType);
                if ~isempty(charset)
                    % If there is an explicit or default charset, get the bytes,
                    % either by converting the Data or directly from Payload, and
                    % return them as a Unicode string
                    bytes = obj.getBytes();
                    str = string(native2unicode(bytes(:)', charset));
                    lengthMsg = false;
                    return
                else
                    if strcmpi(obj.ContentType.Type, 'multipart')
                        % for a multipart message, parse the Payload to show the parts, if it was saved.
                        % If it wasn't saved, and Data is an array of Message, print them.
                        if ~isempty(obj.Payload)
                            [str, lengthMsg] = obj.showMultipartPayload(varargin{:});
                            return;
                        elseif isa(obj.Data, 'matlab.net.http.Message')
                            [str, lengthMsg] = obj.showMultipartData(varargin{:});
                            return;
                        end
                    else
                    end
                end
            end
            % Data not characters or we don't know ContentType; just return length message
            % in bytes
            str = obj.bodyLengthMessageBytes();
            lengthMsg = true;
        end
        
        function [str, lengthMsg] = showMultipartPayload(obj, maxLength)
            data = reshape(obj.Payload,1,numel(obj.Payload)); % make data a row vector
            CRLF = "\r\n";
            boundary = matlab.net.internal.getSafeRegexp(obj.ContentType.getParameter('boundary'));
            if ~isempty(boundary) && strlength(boundary) ~= 0
                regBoundary = "--" + boundary + "\s*?" + CRLF;
                endBoundary = "--" + boundary + "--\s*?" + CRLF;
                partMatcher = "^.*?(" + CRLF + regBoundary + ")|^.*?(?<end>" + CRLF + endBoundary + ")";
                % first get the preamble; everything up to first boundary; no CRLF required
                % before first boundary
                firstMatcher = "^.*?(" + regBoundary + ")|^.*?(?<end>" + endBoundary + ")";
                [lastStr, ext, endStruct] = regexp(char(data), firstMatcher, 'match', 'tokenExtents', 'names', 'once');
                if ~isempty(lastStr)
                    str = string(lastStr); % preamble
                    idx = ext(2) + 1;
                    % keep looping until we find an endBoundary
                    while isempty(lastStr) || (isempty(endStruct.end) && idx < length(data))
                        % lastStr is everything up to next boundary
                        % ext is [first,last] index of the boundary (including CRLFs) into data(idx:end)
                        % endStruct.end is empty if this is not the last boundary; nonempty if last
                        [lastStr, ext, endStruct] = regexp(char(data(idx:end)), partMatcher, 'match', 'tokenExtents', 'names', 'once');
                        if isempty(ext)
                            % no boundary found; possible message was prematurely ended
                            lastStr = char(data(idx:end));
                            dataEnd = length(lastStr);
                        else
                            dataEnd = length(lastStr) - (ext(2) - ext(1) + 1);
                        end
                        mb = matlab.net.http.MessageBody; % dummy MessageBody to use to form part
                        % see if part has any headers; eoh is the index into lastStr of CRLF after the
                        % headers, but first look for a CRLF at the begi
                        eoh = regexp(lastStr, "^\s*?" + CRLF + '|^\s*?' + CRLF + '\s*?' + CRLF, 'end', 'once');
                        charset = [];
                        if ~isempty(eoh)
                            % we see a CRLF at the beginning, so no headers
                            headerStr = "";
                        else
                            % end of headers is at two CRLF's
                            [headerStr, eoh] = regexp(lastStr, "^.*?" + CRLF + CRLF, 'match', 'end','once');
                            % find the Content-Type, if any among headers
                            ctfStr = regexp(headerStr, "Content-Type:\s*(.*?)\s*" + CRLF, 'tokens', 'once'); 
                            if ~isempty(ctfStr)
                                try
                                    % Get its MediaType
                                    mb.ContentType = matlab.net.http.MediaType(ctfStr{1});
                                    charset = matlab.net.internal.getCharsetForMediaType(mb.ContentType);
                                catch
                                end
                            else
                            end
                        end
                        str = str + headerStr;
                        dataStart = eoh + 1;
                        % We have in lastStr:
                        %   CRLF --boundary CRLF headers CRLF ...data... --boundary CRLF
                        %   \_______already in str_________/  |           \____________/
                        %                            lastStr(dataStart)   ext(2)-ext(1)+1
                        %   
                        % now copy any body to the message
                        if dataEnd >= dataStart
                            uintData = uint8(char(lastStr(dataStart:dataEnd)));
                            if ~isempty(charset)
                                mb.DataInt = native2unicode(uintData, charset);
                            else
                                mb.Payload = uintData;
                            end
                        end
                        if nargin > 1
                            str = str + mb.show(maxLength);
                        else
                            str = str + mb.show();
                        end
                        if ~isempty(ext)
                            % add boundary to the output
                            str = str + char(data(idx + ext(1) - 1:idx + ext(2) - 1));
                            idx = idx + ext(2) - 1;
                        else
                            % no boundary found after this part; end message
                            break
                        end
                    end
                else
                end
            else
            end
            lengthMsg = false;
        end
        
        function [str, lengthMsg] = showMultipartData(obj, varargin)
        % Called to show Data with it's a vector of Message (i.e., a multipart response)
        % when obj.Payload is empty
            data = obj.Data;
            assert(isa(data,'matlab.net.http.Message'));
            str = "";
            for i = 1 : length(data)
                str = str + "----------- Part " + string(i) + ' ------------' + newline + ...
                	data(i).show(varargin{:});
            end
            lengthMsg = false;
        end
    end
    
end



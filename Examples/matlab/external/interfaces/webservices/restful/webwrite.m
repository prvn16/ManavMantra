function varargout = webwrite(url, varargin)
%WEBWRITE Write data to RESTful web service
%
%   Syntax
%   ------
%   RESPONSE = WEBWRITE(URL,PostName1,PostValue1, ...)
%   RESPONSE = WEBWRITE(URL,DATA)
%   RESPONSE = WEBWRITE(__,OPTIONS)
%   [RESPONSE,__] = WEBWRITE(__)
%
%   Description 
%   ------------
%   RESPONSE = WEBWRITE(URL,PostName1,PostValue1, ...) posts content to the web
%   service specified by the string URL and returns the response in RESPONSE.
%   WEBWRITE encodes the name, value pairs PostName1, PostValue1, ..., in the
%   body of the message and sets the media type to
%   'application/x-www-form-urlencoded'. WEBWRITE posts the content to the web
%   service using an HTTP POST request. The name,value parameters supported by
%   the web service are defined in the service's documentation. Numeric and
%   logical values are encoded as strings using NUM2STR. Nonscalar values are
%   encoded as specified by the default ArrayFormat property of WEBOPTIONS.
%   WEBWRITE sets additional HTTP request parameters with the default property
%   values of WEBOPTIONS.
%
%   RESPONSE = WEBWRITE(URL, DATA) posts DATA to the web service and sets the
%   media type based on the data (see below).
%
%   RESPONSE = WEBWRITE(__, OPTIONS) sets HTTP request parameters with the
%   property values of the WEBOPTIONS object OPTIONS. Set the RequestMethod
%   property of OPTIONS to 'put' or some other method if you need to use a
%   method other than POST when sending data to a RESTful web service.  When
%   specifying PostName,PostValue parameters, changing the RequestMethod does
%   not affect where the query parameters are placed: they always appear in the
%   body of the message.  To place parameters in the URL, use WEBREAD.
%
%   If DATA is not form encoded ('application/x-www-form-urlencoded'), set the
%   options.MediaType property value to a different string value. WEBWRITE
%   includes this value in the request sent to the server. The server might
%   issue an error if the value is incorrect. For a complete list of values,
%   refer to <a href="matlab:web('http://www.iana.org/assignments/media-types/media-types.xhtml')">Internet media types.</a> WEBWRITE does not validate the value against 
%   this list of media types.
%
%   [RESPONSE, __] = WEBWRITE(__) returns multiple response values from the
%   web service if the response is an indexed image or audio data, or if
%   you set options.ContentReader and your content reader returns multiple
%   outputs.
%
%   Input Arguments
%   ---------------
%
%   Name       Description                                Data Type
%   ----  --------------------                            ---------
%   URL   Web address of server including the             string or character
%         transfer protocol, http or https.               vector
%         The URL is automatically encoded.
%
%   PostName
%         Name of data to post to web service             string or character
%                                                         vector
%   PostValue
%         Value of data to post to web service.           string; vector of
%         If you specify a datetime you must specify      numeric, char, logical
%         its Format property as expected by the web      or datetime; 2-D 
%         service.  If it is a non-scalar vector or cell  array of char; or
%         vector, or char array with more than one row,   cell array containing
%         the value is processed according to the         strings or numeric,
%         ArrayFormat property of WEBOPTIONS.             logical or datetime
%                                                         scalars
%
%   DATA  Data to post to web service. If a character     string or character
%         vector, it will be sent as-is, without          vector, and if json 
%         conversion.  All other types are converted      MediaType, numeric,
%         based on weboptions.MediaType.                  cell, logical or
%                                                         structure; if XML 
%                                                         MediaType, Document 
%                                                         Object Model
%
%   OPTIONS
%         Other options used to connect to web            scalar WEBOPTIONS object
%         service and to define media type
%
%   Output Arguments
%   ---------------
%
%   Name       Description                 Data Type
%   ----       --------------------        ---------
%   RESPONSE   Response from web service   Dependent on web service
%                                          and value of options.ContentType
%                                          and options.ContentReader
%
%   % Example
%   % -------
%   % Write a number to the ThingSpeak server. 
%   % Create a ThingSpeak account at https://thingspeak.com.
%   % Obtain your Write API Key and Channel ID.
%   % Save these values to a MAT-file:
%   %    writeApiKey = 'Your_Write_API_Key';
%   %    channelID = Your_Channel_ID_Number;
%   %    save thingSpeakApi.mat writeApiKey channelID
%   load thingSpeakApi
%   thingSpeakURL = 'http://api.thingspeak.com';
%   thingSpeakWriteURL = [thingSpeakURL '/update'];
%   fieldName = 'field1';
%   fieldValue = 42;
%   response = webwrite(thingSpeakWriteURL,'api_key',writeApiKey,fieldName,fieldValue)
%
%   % Read back the number you wrote to your channel. ThingSpeak  
%   % provides a different URL to get the last entry to your channel.  
%   % Your channel ID is part of the URL. You can use the write API key 
%   % to read or write data to the channel.
%   channels = ['/channels/' num2str(channelID)];
%   fields = ['/fields/' fieldName '/last'];
%   thingSpeakReadURL = [thingSpeakURL channels fields];
%   data = webread(thingSpeakReadURL,'api_key',writeApiKey)
%   
%   See also DATETIME, WEBREAD, WEBOPTIONS, WEBSAVE, XMLWRITE, JSONENCODE

% Copyright 2014-2017 The MathWorks, Inc.

    % Need at least 2 inputs.
    narginchk(2,inf)

    % Parse inputs.
    [postData, options] = parseInputs(mfilename, varargin);

    % Validate request method
    options = validateRequestMethod(options);

    % Encode URL.
    url = urlencode(url);

    % Validate and convert post data to a string, if required.
    [postData, options] = validatePostData(postData, options);

    % Open HTTP connection.
    connection = openHTTPConnection(url, options, postData);

    % Send a request and read the content from the web service.
    [varargout{1:nargout}] = readContentFromWebService(connection, options);
end

%--------------------------------------------------------------------------

function options = validateRequestMethod(options)
% If options.RequestMethod is 'auto', set to 'post'. If
% options.RequestMethod is 'get', then issue an error.

    if strcmp(options.RequestMethod, 'auto')
        options.RequestMethod = 'post';

    elseif strcmp(options.RequestMethod, 'get')
        e = MException(message('MATLAB:webservices:ExpectedPostRequestMethod', ...
            'options.RequestMethod','WEBREAD','options.RequestMethod'));
        throwAsCaller(e);
    end
end

%--------------------------------------------------------------------------

function url = urlencode(url)
% Encode the URL.

    try
        url = matlab.internal.webservices.urlencode(url);
    catch e
        throwAsCaller(e);
    end
end

%--------------------------------------------------------------------------

function [postData, options] = validatePostData(postData, options)
% Validate postData input and convert to string, if needed.  Return any augmented
% options.

    usingNameValuePairs = ~isscalar(postData);
    try
        if usingNameValuePairs
            % Validate and encode postDataName, postDataValue.
            requestName  = 'postName';
            requestValue = 'postValue';
            if strcmpi(options.MediaType,'auto')
                options.MediaType = 'application/x-www-form-urlencoded';
            end
            postData = matlab.internal.webservices.formencode( ...
                options, postData, requestName, requestValue);
        else
            % Validate and convert to string the single postData input.
            [postData, options] = validateSingleInputPostData(postData{:}, options);
        end
    catch e
        throwAsCaller(e);
    end

end

%--------------------------------------------------------------------------

function [postData, options] = validateSingleInputPostData(postData, options)
% Validate single input postData and convert to string, if needed.  Return any
% augmented options.  char vectors always returned as-is.  If mediaType is not
% application/json, scalar strings are returned as-is.

    mediaType = options.MediaType;
    isAuto = strcmpi(mediaType,'auto');
    if isa(postData, 'org.apache.xerces.dom.DocumentImpl')
        if ~isMediaType('xml') && ~isAuto
            error(message('MATLAB:webservices:ExpectedXMLMediaType', ...
                'options.MediaType'));
        else
            if isAuto
                options.MediaType = 'application/xml';
            end
            postData = xmlwrite(postData);
        end

    elseif isMediaType({'json','javascript'}) || (isAuto && ~ischar(postData) && ~(isstring(postData) && isscalar(postData)))
        postData = dataToJSON(postData);
        if isempty(options.CharacterEncoding) || strcmpi(options.CharacterEncoding, 'auto')
            options.CharacterEncoding = 'UTF-8';
        end
        if isAuto
            options.MediaType = 'application/json';
        end

    elseif isnumeric(postData) || islogical(postData)
        error(message('MATLAB:webservices:UnexpectedMediaType',mediaType));

    elseif any(strcmpi(class(postData),{'cell','struct'}))
        error(message('MATLAB:webservices:ExpectedJSONMediaType', ...
            'options.MediaType'));

    else
        validateattributes(postData, {'char','string'}, {}, mfilename, 'postData');
        if isstring(postData)
            postData = char(postData);
        end
        if isAuto
            options.MediaType = 'application/x-www-form-urlencoded';
        end
    end
 
    %----------------------------------------------------------------------

    function tf = isMediaType(type)
    % Return true if any type is found in mediaType.
        if iscell(type)
            tf = false(1,length(type));
            for k = 1:length(type)
                found = strfind(mediaType, type{k});
                tf(k) = ~isempty(found);
            end
            tf = any(tf);
        else
            tf = contains(mediaType, type);
        end
    end
end

%--------------------------------------------------------------------------

function json = dataToJSON(data)
% Validate and convert data to a JSON string.  If data is a char vector, leave
% unchanged.

    classes = {'char','string','numeric','logical','struct','cell'};
    validateattributes(data, classes, {}, mfilename, 'postData');
    if ischar(data) && isvector(data)
        json = data;
    else
        try
            json = jsonencode(data);
        catch e
            exc = MException(message('MATLAB:webservices:JSONConversion'));
            exc = exc.addCause(e);
            throw(exc);
        end
    end
end

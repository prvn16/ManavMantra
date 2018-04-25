function data = ...
    decodeByteArray(byteArray, charSet, urlContentType, options, url)
%decodeByteArray Decode byteArray based on content type
%
%   Syntax
%   ------
%   DATA = decodeByteArray(byteArray, charSet, urlContentType, OPTIONS)
%
%   Description
%   -----------
%   DATA = decodeByteArray(byteArray, charSet, urlContentType, OPTIONS)
%   decodes the uint8 byte array, byteArray, into a MATLAB data type, DATA,
%   based on the content type in urlContentType and OPTIONS. charSet is the
%   character encoding for string data.
%
%   See also WEBREAD, WEBSAVE

% Obtain the decoder function.
decoder = dataStreamDecoder(charSet, urlContentType, options);

% Decode the data stream.
try
    data = decoder(byteArray);
catch e
    % On any error replace the exception with our own, but include the error's
    % message
    exc = MException(message('MATLAB:webservices:ContentTypeReaderError', ...
                     e.message, url, 'WEBSAVE'));
    % Also copy e's causes
    for i = 1 : length(e.cause)
        exc = exc.addCause(e.cause{i});
    end
    throw(exc);
end

%--------------------------------------------------------------------------

function decoder = dataStreamDecoder(charSet, urlContentType, options)
% Obtain the decoder function based on content type.

% Determine content type. If options.ContentType is 'auto', select content
% type from the URL connection, otherwise select the one specified in
% options.
if strcmp(options.ContentType, 'auto')
    contentType = urlContentType;
else
    contentType = options.ContentType;
end

% Construct the decoder anonymous function based on content type. 
% The function will be called with byteArray as the first argument.
switch contentType
    case 'text'
        % decodeTextStream(byteArray, charSet);
        decoder  = @(x) decodeTextStream(x, charSet);
        
    case 'json'
        % decodeJSONStream(byteArray, charSet);
        decoder = @(x) decodeJSONStream(x, charSet);
        
    case 'binary'
        % decodeBinaryStream(byteArray);
        decoder = @(x) decodeBinaryStream(x);
        
    case 'raw'
        % decodeRawStream(byteArray, options.CharacterEncoding, type);
        type = urlContentType;
        decoder = @(x) decodeRawStream(x, options.CharacterEncoding, type);
        
    otherwise
        % decodeBinaryStream(byteArray);
        decoder = @(x) decodeBinaryStream(x);
end

%--------------------------------------------------------------------------

function data = decodeTextStream(byteArray, charSet)
% Decode text stream.

data = native2unicode(byteArray',charSet);

%--------------------------------------------------------------------------

function data = decodeJSONStream(byteArray, charSet)
% Decode JSON stream.

if isempty(charSet)
    charSet = 'UTF-8'; % Default encoding for JSON
end
% Check for UTF-8
if strcmpi('UTF8', strrep(charSet, '-', ''))
    % Check for UTF-8 BOM at beginning of byteArray
    if length(byteArray) > 3 && isequal(uint8([239; 187; 191]), byteArray(1:3))
        % remove the UTF-8 BOM
        byteArray = byteArray(4:end);
    end
end
jsonStr = decodeTextStream(byteArray, charSet);
try
    if(isempty(jsonStr)) % Fix to accomodate the empty type to return ''
        data = '';       % instead of {} as for connector.
    else    
        data = jsondecode(jsonStr);
    end
catch e
    jsonStr = jsonStr(:)';
    exc = MException(message('MATLAB:webservices:InvalidJSON', jsonStr));
    exc = exc.addCause(e);
    throw(exc);
end

%--------------------------------------------------------------------------

function data = decodeBinaryStream(byteArray)
% Decode binary stream and return a uint8 column vector.

data = byteArray;

%--------------------------------------------------------------------------

function data = decodeRawStream(byteArray, charSet, contentType)
% Decode raw stream. Return a char column vector for json, xmldom, and text
% content type. Apply native2unicode conversion, only if charSet is not
% auto. Return a uint8 column vector for all others.

% Return text, json, xmldom as text, all others as binary.
if any(strcmp(contentType, {'text', 'json', 'xmldom'}))
    % contentType is json, xmldom, or text, return a character array.
    if strcmp(charSet, 'auto')
        % Raw character array column vector.
        data = char(byteArray);
    else
        % Apply encoding.
        data = native2unicode(byteArray,charSet);
    end
else
    % contentType is not json, xmldom, or text. Return the raw byteArray as
    % a column vector.
    data = byteArray;
end

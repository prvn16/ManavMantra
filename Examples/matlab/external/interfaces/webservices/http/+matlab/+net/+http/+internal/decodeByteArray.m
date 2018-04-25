function data = ...
    decodeByteArray(byteArray, charset, simpleType, url, convert)
%decodeByteArray Decode byteArray based on content type
%   This function is called to convert incoming data in byteArray that doesn't
%   first need to be written to a file.  Currently this is only invoked for
%   text-based or binary data.

%   DATA = decodeByteArray(byteArray, charset, simpleType, url, convert) 
%
%   If convert is set, decodes the uint8 byte array, byteArray, into a MATLAB data
%   type, DATA, based on the simpleType.  charset is the character encoding for
%   character data, used, for example, when simpleType is 'text' or 'json'.  If
%   simpleType is empty just returns byteArray.  
%
%   If convert is false, just decode based on charset, if any.  If there is no
%   charset, return byteArray.
%
%   Throws ExceptionWithPayload on any error.

% Copyright 2015-2016 The Mathworks, Inc.

    % Obtain the decoder function.
    decoder = dataStreamDecoder(charset, simpleType, convert);

    % Decode the data stream.
    try
        data = decoder(byteArray);
    catch e
        if (isa(e, 'matlab.net.http.internal.ExceptionWithPayload'))
            % In this case, the decoder has formed an ExceptionWithPayload containing
            % the information we want to communicate to the user.  This exception
            % may provide both Payload and Data
            rethrow(e);
        else
            % Some other exception where we could not get the Data
            if ~isempty(url)
                me = MException(message('MATLAB:http:CannotConvertContent', ...
                                       url, simpleType));
            else
                me = MException(message('MATLAB:http:CannotConvertPayload', ...
                                       simpleType));
            end
            me = me.addCause(e);
            throw(matlab.net.http.internal.ExceptionWithPayload(byteArray, me));
        end
    end
end

%--------------------------------------------------------------------------

function decoder = dataStreamDecoder(charset, simpleType, convert)
% Obtain the decoder function based on content type.  If convert is false, only do
% charset encoding if charset is set.

    % Construct the decoder anonymous function based on content type. 
    % The function will be called with byteArray as the first argument and possibly
    % charset as the 2nd.
    
    binaryDecoder = @(x) decodeBinaryStream(x);
    
    if ~convert
        if ~isempty(charset)
            decoder = @textDecoder;
        else
            decoder = binaryDecoder;
        end
    else
        if isempty(simpleType)
            simpleType = '';
        end
        switch simpleType
            case 'text'
                decoder = @textDecoder;
            case 'json'
                % decodeJSONStream(byteArray, charset);
                decoder = @(x) decodeJSONStream(x, charset);
            case 'binary'
                decoder = binaryDecoder;
            otherwise
                % no simpleType or not one of above, treat as text or binary
                % depending on whether we know charset
                if ~isempty(charset)
                    decoder = @textDecoder;
                else
                    decoder = binaryDecoder;
                end
        end
    end
    
    function data = textDecoder(bytes)
    % Return decoded bytes as a string.  Returns string.empty if bytes are empty.
        if isempty(bytes)
            data = string.empty;
        else
            data = string(decodeTextStream(bytes, charset));
        end
    end
end

%--------------------------------------------------------------------------

function data = decodeTextStream(byteArray, charset)
% Decode a byteArray to return char vector.  Invalid charset throws.
    data = native2unicode(byteArray', charset); 
end

%--------------------------------------------------------------------------

function data = decodeJSONStream(byteArray, charset)
% Decode JSON stream.

    if strlength(charset) == 0
        charset = 'UTF-8'; % Default encoding for JSON
    end
    % Check for UTF-8
    if strcmpi('UTF8', strrep(char(charset), '-', ''))
        % Check for UTF-8 BOM at beginning of byteArray
        if length(byteArray) > 3 && isequal(uint8([239; 187; 191]), byteArray(1:3))
            % remove the UTF-8 BOM
            byteArray = byteArray(4:end);
        end
    end
    jsonStr = decodeTextStream(byteArray, charset);
    try
        data = jsondecode(jsonStr);
    catch e
        jsonStr = jsonStr(:)';
        throw(matlab.net.http.internal.ExceptionWithPayload(byteArray, ...
            e, ...
            string(jsonStr), charset));
    end
end

%--------------------------------------------------------------------------

function data = decodeBinaryStream(byteArray)
% Decode binary stream and return a uint8 column vector.

    data = byteArray;
end

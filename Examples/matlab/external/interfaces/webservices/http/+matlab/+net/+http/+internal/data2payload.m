function [payload, mediaType] = data2payload(data, mediaType)
%data2payload Convert the MATLAB data to an HTTP RequestMessage payload
%   [data, payload, mediaType] = data2payload(data, mediaType)
%   
%   This function is used to send MATLAB data in an HTTP request
%
%   data        The data to be converted. This is normally the MessageBody.Data,
%               which, for some types (like image), could be a cell array of values
%               to be passed to a converter (e.g., imwrite).
%
%   mediaType   A MediaType.  On input, this is normally the MessageBody.ContentType 
%               that was set from the ContentTypeField in the RequestMessage.
%               However it may be [] if the user did not specify the
%               ContentTypeField, or if we are being asked to convert data that has
%               not yet been attached to a RequestMessage.  On output, this is the
%               same as the input contentType, if specified, or the Content-Type we
%               computed based on the type of data.
%
%               This value might contain only a charset and no Type or
%               Subtype.  (This happens when we were called to reconvert data
%               that was converted to Unicode but failed subsequent conversion
%               or user suppressed conversion.)  If so, then we just convert the
%               data based on the charset.  This case is allowed only if data
%               is char or string.
%
%   payload     A uint8 vector containing the converted data.  If data is [] then
%               then this is [].
%   
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2017 The MathWorks, Inc.

    import matlab.net.http.internal.* %#ok<NSTIMP>
    import matlab.net.internal.* %#ok<NSTIMP>
    
    % These are maps to convert between the MATLAB name for the type used by commands
    % that convert data based on the type, e.g., 'pnm' for image data, to the
    % type/subtype Internet Media type, e.g. 'image/x-portable-anymap'.  It is
    % assumed that subtypes are unique across all types.
    [matlabTypeToType, subtypeToMatlabType] = getTypeMaps();
    % this says it's a "single string"
    isString = @(s) (ischar(s) && isrow(s)) || (isstring(s) && isscalar(s));
    
    if ~isempty(mediaType) && isempty(mediaType.Type)
        % The contentType is specified, but it contains no Type (and presumably no
        % Subtype) -- just a charset.  This case only used to reprocess a payload that
        % was converted to string data using a charset, but no other conversion was
        % done.  Such a ContentType is set in a MessageBody by RequestMessage when,
        % for example, ConvertResponse is false or there was a conversion error.  In
        % this case we get called by ResponseMessage.complete to unconvert the string
        % back to a payload using that charset.
        charset = mediaType.getParameter('charset');
        assert((ischar(data) || isstring(data)) && ~isempty(charset));
        % no need to catch exception here because presumably we already successfully
        % used this charset to convert payload using native2unicode.
        payload = unicode2native(data, charset)'; 
        return;
    else
        % Get the content type based on the data, if not already specified, and its
        % charset.  Always returns nonempty charset for string and char data even if not
        % specified in the contentType.
        [mediaType, charset, data, isSpreadsheet] = deriveMediaType(data, mediaType);
        payload = [];
    end
    charset = char(charset); % so [] and '' and "" are equivalent
    mt = @(ct) matlab.net.http.MediaType(ct.Type + '/' + ct.Subtype);
    if ~isempty(charset) && (ischar(data) || isstring(data)) && ...
            ~(mt(mediaType) == matlab.net.http.MediaType('application/json')) 
        % If there is a charset and it's character data, and contentType is not
        % applicaton/json, convert it using charset and we're done.  application/json is the only
        % content type for which we convert string or char data specially.        
        try
            data = getSingleStringFromData(data);
            % Encode it using the charset and make column vector
            payload = unicode2native(data, charset)'; 
        catch e
            % not clear if there's any way for unicode2native to fail, but it should
            % (e.g., non-ASCII characters for charset of us-ascii)
            throwConversionError(data, mediaType, e);
        end
    elseif (isSpreadsheet || strcmpi(mediaType.Subtype, 'csv')) && ...
            (istable(data) || (iscell(data) && istable(data{1})))
        % If it's a table and the ContentType says to write it as spreadsheet or csv
        % data, get the format for writetable.  This should be 'text' or
        % 'spreadsheet'.  If not, writetable bombs.
        fmt = getFormat(mediaType);
        try
            switch(fmt)
                case 'text'
                    suffix = 'csv';
                case 'spreadsheet'
                    % For this type the suffix depends on the media type
                    suffix = matlab.net.http.internal.getSuffixForSubtype('table', mediaType.Subtype);
                otherwise
                    % This probably does nothing useful, but if writetable is enhanced to
                    % handle other types, this might work
                    suffix = fmt;
            end
            tempfile = [tempname '.' suffix];
            if ~isempty(charset)
                % Since writetable doesn't let you specify a charset, we need to change
                % MATLAB's default charset.
                oldDFC = feature('DefaultCharacterSet', charset);
                clean = onCleanup(@()feature('DefaultCharacterSet', oldDFC));
            end
            if iscell(data)
                % Pass arguments from cell array into writetable. This will generate an error
                % if user specified a 'FileType' inconsistent with the suffix computed, e.g.
                % fmt computed from contentType is 'spreadsheet', which requires a suffix of
                % 'xls', but FileType is 'text'.
                writetable(data{1}, tempfile, data{2:end});
            else
                writetable(data, tempfile);
            end
            clear clean
            % get raw bytes from file
            payload = getPayload(tempfile);
        catch e
            throwConversionError(data, mediaType, e);
        end
    else
        % No charset, or data isn't a char, string or table, or type is
        % application/json.
        % Note we might come here for 'text' types if the data wasn't a char or
        % string.  Decide what to do based on the specified or derived contentType.
        try
            switch(lower(mediaType.Type))
                case 'image'
                    % For image, we need to use imwrite to convert it to a payload. To do
                    % so we need to know the value of the format parameter to imwrite.
                    % If the user has specified such a parameter in data{2}, we'll use
                    % that.
                    tempfile = tempname;
                    if iscell(data)
                        fmt = getFormat(mediaType);
                        if isscalar(data) || isempty(data{2})
                            % if there is no 'fmt' argument in data{2}
                            imwrite(data{1}, tempfile, fmt, data{3:end});
                        elseif ~isString(data{2})
                            % If data{2} isn't a string, then assume it's a colormap for
                            % indexed image and pass in the filename as the 3rd
                            % argument.  This is fragile: if imwrite ever changes its
                            % API this can break.

                            % if there are an odd number of parameters after the data,
                            % assume the first one is the format, so don't use ours.
                            % Otherwise plug in our computed fmt.
                            if mod(length(data), 2) == 0
                                imwrite(data{1}, data{2}, tempfile, fmt, data{3:end});
                            else
                                imwrite(data{1}, data{2}, tempfile, data{3:end});
                            end
                        elseif mod(length(data), 2) ~= 0
                            imwrite(data{1}, tempfile, fmt, data{2:end});
                        else
                            imwrite(data{1}, tempfile, data{2:end});
                        end
                    else
                        % if data isn't of the correct format, or getFormat doesn't
                        % return anything useful, this just bombs
                        imwrite(data, tempfile, getFormat(mediaType));
                    end
                    payload = getPayload(tempfile);
                case 'audio'
                    if iscell(data) && length(data) > 1
                        % We can only handle audio data that consists of two or more
                        % arguments to audiowrite, the data and the sampling rate.  The
                        % format that audiowrite uses is based on the suffix of the temp
                        % file name, and we get that format from the Content-Type header.
                        payload = getAudioPayload(data, getFormat(mediaType));
                    end
                case 'application'
                    switch(lower(mediaType.Subtype))
                        case 'octet-stream'
                            if isa(data, 'uint8')
                                % for raw octets, payload is simply data reshaped to vector by
                                % column
                                payload = data(:); 
                            end
                        case 'json'
                            data = jsonencode(data);
                        case 'xml'
                            data = xmldom2string(data);
                        case 'ogg'
                            if iscell(data) && length(data) > 1
                                payload = getAudioPayload(data, getFormat(mediaType));
                            end
                        case 'x-www-form-urlencoded'
                            if isa(data, 'matlab.net.QueryParameter')
                                data = char(data);
                            end
                    end
                case 'text'
                    % We get here if contentType was explicitly specified as text but the
                    % data isn't a string or char. 
                    if strcmpi(mediaType.Subtype,'xml')
                        data = xmldom2string(data);
                    else
                        % Try to convert it to a string; this
                        % may error out if the char or string function doesn't work on the
                        % type.  We do this for the benefit of people who implement a char or
                        % string method for their object, or to take advantage of the fact
                        % that string will convert a number to a string.  
                        newdata = [];
                        try 
                            % try string first, because calling char on a number array is
                            % unlikely to do the desired thing
                            newdata = strjoin(string(data)); % concatenates with space
                        catch 
                            try
                                newdata = char(data);
                                if iscellstr(newdata)
                                    newdata = strjoin(newdata);
                                end
                            catch
                            end
                        end
                        if ~isempty(newdata) && ischar(newdata) || isstring(newdata) 
                            % conversion worked
                            if isempty(charset)
                                charset = getCharsetFromData(newdata);
                            else
                                data = newdata;
                            end
                        end
                    end
            end
        catch e
            throwConversionError(data, mediaType, e);
        end
        if isempty(payload) 
            % payload not set; didn't do any conversions above except stringification of
            % data
            if isString(data)
                % if data is a string, convert to native bytes make column vector for
                % consistency
                payload = unicode2native(data, charset)'; 
            elseif ~isempty(data)
                % if we couldn't convert data to a payload, error out if there was data
                dims = strjoin(arrayfun(@num2str, size(data), 'UniformOutput', false), ',');
                error(message('MATLAB:http:DataInconsistentWithContentType',...
                      class(data), dims, char(mediaType)));
            end
        end
    end

    function [mediaType, charset, data, isSpreadsheet] = deriveMediaType(data, mediaType)
    % deriveMediaType(data, mediaType) heuristically determines the content type
    %   based on data, if contentType not specified.  Otherwise just returns
    %   contentType.
    %
    %   mediaType     MediaType or [].  Returns derived mediaType if input was [].
    %                 May contain only a charset (no Type/Subtype).  In this case
    %                 data must be a string or char and we return [].
    %   data          The data (must be nonempty).  Returns the same data, except
    %                 cellstrs and string vectors are concatenated into a single
    %                 string if not otherwise proecessed.
    %   charset       The explicit or assumed charset, if character data, or ''.
    %                 Always returns nonempty value for character data.  However may
    %                 return a charset for non-character data if it was specified in
    %                 or implied by contentType.  Doesn't verify that an explicitly
    %                 specified charset actually makes sense for the data or
    %                 MediaType.
    %   isSpreadsheet True if returned type implies spreadsheet
    %
    % Throws an exception if contentType is specified and inconsistent with data type

        import matlab.net.internal.*
        charset = [];
        % compute this once because iscellstr could be time consuming
        isStringArray = (ischar(data) && ~isvector(data)) || iscellstr(data) || ...
                        (isstring(data) && length(data) > 1);
        isSpreadsheet = false;
        if isempty(mediaType)
            if iscell(data) && ~isStringArray
                % if data is a cell array other than a cellstr, this likely means
                % that it's an array of arguments for conversion functions like
                % imwrite or audiowrite. The first element is the actual data.
                if isvector(data)
                    actData = data{1};
                end
                if ~isvector(data) || isempty(actData)
                    error(message('MATLAB:http:CannotDeriveContentType', 'cell', ...
                                   dimsStr(data)));
                end
            else
                actData = data;
            end
            % If no contentType, set it based on data.  This isn't very reliable.
            assert(~isempty(actData));
            type = '';
            if isnumeric(actData) || islogical(actData)
                % a uint8 array is either image, audio or raw data
                isunsigned = @(cls) cls(1) == 'u'; % true if class name begins with u
                if ismatrix(actData) && iscell(data) && ...
                         length(data) >= 2 && ... 
                         isnumeric(data{2}) && isscalar(data{2}) && data{2} > 0
                    % An mxn matrix followed by a positive scalar is assumed to be
                    % audio data (as per audiowrite)
                    % Since no ContentType specified, use wav, because it's universal.
                    % Caller can't specify the format because audiowrite doesn't have
                    % an explicit format parameter: it's assumed from the file name
                    % extension which the user doesn't specify here.  All audio data
                    % looks the same internally.
                    mt = matlabTypeToType('wav');
                    type = mt{1};
                    subtype = mt{2};
                elseif ~isvector(actData)
                    % For a numeric or logical non-vector, see if it looks like image
                    % data as per imwrite.  If input is a cell array, and the
                    % parameter at nextArg is an image format, then use that for the
                    % image type. Otherwise, guess the type.
                    nextArg = 2;
                    mtype = ''; % the MATLAB type based on data (fmt param to imwrite)
                    if ndims(actData) == 3 
                        if size(actData,3) == 3 
                            % assume mxnx3 is an RGB JPEG image
                            mtype = 'jpeg';
                        elseif size(actData,3) == 4
                            % assume mxnx4 is a CMYK TIFF image
                            mtype = 'tiff';
                        end
                    elseif ismatrix(actData) 
                        % All mxn numeric or logical matrices come here
                        if isunsigned(class(actData)) && ...
                           iscell(data) && ismatrix(data{2}) && size(data{2},2) == 3
                            % assume mxn uint* followed by mx3 matrix is an indexed
                            % image
                            mtype = 'gif';
                            % For a gif image, data{2} should be the map and data{3},
                            % if it appears, would be the format.
                            nextArg = 3;
                        else
                            % Other mxn numeric array assumed to be PNG grayscale. It
                            % is a rather rash assumption that this is even an image.
                            mtype = 'png';
                        end
                    end
                    if iscell(data) && length(data) >= nextArg && ischar(data{nextArg})
                        % If the nextArg'th parameter in the cell array data is an
                        % image format in our list, use it in place of the subtype we
                        % derived from the data.
                        arg = lower(data{nextArg});
                        if matlabTypeToType.isKey(arg)
                            mt = matlabTypeToType(arg);
                            if strcmpi(mt{1},'image')
                                mtype = mt{2};
                            end
                        end
                    end
                    if ~isempty(mtype)
                        % if any of above succeeded in determining a MATLAB type,
                        % then assume it's image
                        mt = matlabTypeToType(mtype);
                        type = mt{1};
                        subtype = mt{2};
                    end
                elseif isa(actData,'uint8') && ~iscell(data)
                    % a uint8 vector with no other parameters is just octets
                    type = 'application';
                    subtype = 'octet-stream';
                end
                charset = '';
            elseif istable(actData)
                % a table; use additional args as writetable name,value parameters
                mtype = 'text';
                if iscell(data)
                    % See if there's a FileType argument (would be 'text' or
                    % 'spreadsheet')
                    for i = 1 : length(data)
                        if strcmpi(data{i},'FileType') && i < length(data)
                            mtype = char(data{i+1});
                        end
                    end
                end
                if matlabTypeToType.isKey(mtype)
                    mt = matlabTypeToType(mtype);
                    type = mt{1};
                    subtype = mt{2};
                    isSpreadsheet = true;
                end
            elseif isStringArray || isString(data)
                % all string data is assumed plain text; allow cellstrs or any char or string
                % array
                type = 'text';
                subtype = 'plain';
                charset = getCharsetFromData(data);
            elseif isstruct(data) || iscell(data)
                % struct or cell is assumed JSON
                type = 'application';
                subtype = 'json';
                charset = 'utf-8';
            elseif isa(data, 'org.w3c.dom.Document')
                % if the data is an XML DOM, we'll use xmlwrite to convert it.  Use
                % applicaton/xml as the Content-Type.
                type = 'application';
                subtype = 'xml';
            elseif isa(data, 'matlab.net.QueryParameter')
                type = 'application';
                subtype = 'x-www-form-urlencoded';
            end
            if isempty(type)
                error(message('MATLAB:http:CannotDeriveContentType', ...
                    class(actData), dimsStr(actData)));
            end
            % make a MediaType from the typeStr and set if charset, if relevant
            mediaType = matlab.net.http.MediaType([type '/' subtype]);
            if ~isempty(charset)
                mediaType = mediaType.setParameter('charset',charset);
            end
        end
        % contentType is now a nonempty MediaType; get its charset
        % This is either explicit in the contentType or assumed from the MediaType's
        % default encoding.  This may be empty if it's not character data.
        charset = getCharsetForMediaType(mediaType);
        if isempty(charset) && (isStringArray || ischar(data) || isstring(data))
            data = getSingleStringFromData(data);
            % if charset not specified and it's a string, derive from data
            charset = getCharsetFromData(data);
            mediaType = mediaType.setParameter('charset',charset);
        end
        if nargout > 3 && ~isSpreadsheet
            % see if subtype is one of the spreadsheet or csv types
            lst = char(lower(mediaType.Subtype));
            isSpreadsheet = strcmpi(mediaType.Subtype, 'csv');
            if ~isSpreadsheet && subtypeToMatlabType.isKey(lst)
                mtype = subtypeToMatlabType(lst);
                isSpreadsheet = strcmpi(mtype{2}, 'spreadsheet');
            end
        end
    end

    function format = getFormat(contentType)
    % Return the MATLAB format name as a char vector, given a contentType.  Returns
    % the plain subtype if not found in our list.
    % TBD string: return string when imwrite accepts string for format
        format = char(lower(contentType.Subtype)); 
        % See if the subtype is in our list of known subtypes.
        if subtypeToMatlabType.isKey(format) 
            matlabType = subtypeToMatlabType(format);
            if strcmpi(contentType.Type, matlabType{1}) % check that type matches
                format = matlabType{2};
            end
        end
        format = char(format); 
    end
end

function str = dimsStr(c)
% return a string naming dimensions of c
   str = strjoin(strsplit(num2str(size(c))),',');
end

function payload = getPayload(tempfile)
% Return the contents of tempfile as a uint8 column vector and delete the file
    deleteit = onCleanup(@() delete(tempfile));
    fid = fopen(tempfile);
    closeit = onCleanup(@() fclose(fid));
    payload = fread(fid,'uint8=>uint8');
    clear closeit
end

function data = xmldom2string(data)
% Convert an XML DOM to an XML string.  Error out if it's not a DOM.
    if ~isa(data,'org.w3c.dom.Document')
        error(message('MATLAB:http:BadXMLType', class(data))); 
    end
    try
        data = xmlwrite(data);
    catch e
        error(message('MATLAB:http:XMLException', e.message));
    end
end

function throwConversionError(data, contentType, e)
    error(message('MATLAB:http:CannotConvertBody', class(data), ...
                  dimsStr(data), char(contentType), e.getReport()));
end

function payload = getAudioPayload(data, format)
% Convert data (cell array of audiowrite parameters) into payload based on format
    tempfile = [tempname '.' format];
    try
        audiowrite(tempfile, data{:});
    catch e
        if strcmp(e.identifier, 'MATLAB:audiovideo:audiowrite:invalidFileExtension')
            error(message('MATLAB:http:CannotConvertAudioType', format, 'flac wav x-wav vnd.wav mp4 ogg'));
        else
            rethrow(e);
        end
    end
    payload = getPayload(tempfile);
end

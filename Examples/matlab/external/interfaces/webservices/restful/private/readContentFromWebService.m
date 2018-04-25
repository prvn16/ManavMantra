function varargout = readContentFromWebService(connection, options)
%readContentFromWebService Read content from Web service
%
%   Syntax
%   ------
%   varargout = readContentFromWebService(connection, options)
%
%   Description
%   -----------
%   varargout = readContentFromWebService(connection, options) reads the
%   content from the Web service indicated by connection.URL and returns
%   the response in varargout. The response is decoded based on property
%   values of options.
%
%   See also WEBREAD, WEBOPTIONS, WEBSAVE, WEBWRITE

% Copyright 2014 The MathWorks, Inc.

% Convert the URL connection content type (e.g. text/plain,
% application/json, etc) to the options form (e.g. text, json, etc)
urlContentType = connectionToOptionsContentType( ...
    connection.ContentType, options.ContentType);

% Validate content type.
url = connection.URL;
validateContentType(urlContentType, options.ContentType, url);

% Determine if content requires file download.
downloadToFile = contentRequiresFileDownload(urlContentType, options);

% Determine character encoding. If 'auto', use encoding from the
% connection.
if ~strcmp(options.CharacterEncoding, 'auto')
    charSet = options.CharacterEncoding;
else
    charSet = connection.CharacterSet;
end

try
    if ~downloadToFile
        % Content does not require downloading to file. Only one output is
        % allowed. 
        nargoutchk(0, 1)

        % Copy the data stream from the connection to byteArray.
        byteArray = copyContentToByteArray(connection);

        % Decode the byte array.    
        varargout{1} = ...
            decodeByteArray(byteArray, charSet, urlContentType, options, url);
        if options.Debug
            connection.log(varargout{1});
        end
    else
        % Assign a filename using the extension of the URL.
        filename = assignFilenameFromURL(url);

        % Delete the file on exit.
        deleteFileObj = onCleanup(@()deleteFile(filename));

        % Copy the content from the Web service to a file.
        copyContentToFile(connection, filename);

        % Read the content from the downloaded file.
        [varargout{1:nargout}] = ...
            readContentFromFile(filename, charSet, urlContentType, options, url);
        if options.Debug
            connection.log(varargout{1});
        end
    end
catch e
    if options.Debug
        connection.log('');
    end
    rethrow(e)
end

%--------------------------------------------------------------------------

function validateContentType(urlContentType, contentType, url)
% Validate content type. If options.ContentType (contentType) is not 'auto', and
% not equal to urlContentType, then allow specific content type to be converted,
% see table below.
%
% urlContentType   options.ContentType
% --------------   -------------------
%          any  -> raw
%          any  -> binary
%          any  -> text
%          text -> json
%        binary -> any

if ~strcmp(urlContentType,'binary') && ...
   ~any(strcmp(contentType, {'auto', 'binary', 'raw', 'text'})) && ...         
   ~isequal(contentType, urlContentType) && ...
   ~(strcmp(urlContentType, 'text') && strcmp(contentType, 'json'))
        
    % We can only convert the types listed in the table.
    id = 'MATLAB:webservices:ContentTypeMismatch';
    msg = message(id, ...
        'options.ContentType', contentType, urlContentType,  url, ...
        'options.ContentType', urlContentType);
    e = MException(id,'%s',msg.getString());
    throwAsCaller(e);
end

%--------------------------------------------------------------------------

function contentType = ...
    connectionToOptionsContentType(urlContentType, optionsContentType)
% Convert the URL connection content type format (which has values such as
% text/plain, application/json, etc), to the options.ContentType format
% (text, json, etc).

% Note: The order in the if statement block is important. Some spreadsheet
% mime-types contain the string 'xmldocument', so it needs to be parsed
% before XML. XML content can be text/xml, so it needs to be parsed before
% text. CSV content is text/csv so it needs to be parsed before text.

if contains(urlContentType, 'json')
    % application/json
    contentType = 'json';
    
elseif contains(urlContentType, 'image')
    % image/jpeg, etc
    contentType = 'image';
    
elseif any(strcmpi(urlContentType, {'text/csv', 'text/comma-separated-values'}))
    % text/csv
    contentType = 'table';
    
elseif contains(urlContentType, 'spreadsheet')
    % spreadsheet (Excel)
    contentType = 'table';
    
elseif contains(urlContentType, 'xml')
    % text/xml, application/xml
    contentType = 'xmldom';
    
elseif isText(urlContentType)
    % text/plain, text/html, application/javascript ...
    contentType = 'text';
        
elseif contains(urlContentType, 'audio')
    % audio
    contentType = 'audio';
    
elseif isempty(urlContentType) && ~strcmp(optionsContentType, 'auto')
    % If undetermined (empty), allow the user to specify.
    contentType = optionsContentType;
    
else
    % default
    contentType = 'binary';
end

%--------------------------------------------------------------------------

function tf = isText(urlContentType)
% Return true if urlContentType is text content.

containsText = contains(urlContentType, 'text');
textContentTypes = { ...
    'application/javascript'
    'application/x-javascript'
    'application/x-www-form-urlencoded'
    'application/vnd.wolfram.mathematica.package' % MATLAB file on some servers
    };
tf = containsText || any(strcmpi(urlContentType, textContentTypes));

%--------------------------------------------------------------------------

function downloadToFile = ...
    contentRequiresFileDownload(urlContentType, options)
% Return true if content requires downloading to a file.

% Download to file if:
% * options.ContentReader has been specified (not empty) or 
% * options.ContentType is not: json, text, binary, raw, auto or
% * options.ContentType is auto and URL content type is not json, text, binary

contentType = options.ContentType;
downloadToFile = ...
    ~isempty(options.ContentReader) || ...
    ~any(strcmp(contentType, {'json', 'text', 'binary', 'raw', 'auto'})) || ...
    (strcmp(contentType, 'auto') && ...
      ~any(strcmp(urlContentType, {'json', 'text', 'binary'})));
        
%--------------------------------------------------------------------------

function filename = assignFilenameFromURL(url)
% Create a filename, preserving the extension of URL. IF URL contains ? or
% the extension is empty, use tempname. Otherwise, use tempname followed by
% the extension. This must be done properly, since some reader functions
% (such as readtable) require the correct extension.

[~, ~, ext] = fileparts(url);
if contains(url, '?') || isempty(ext)
    filename = tempname;
else
    filename = [tempname ext];
end

%--------------------------------------------------------------------------

function deleteFile(filename)
% Delete filename, if it exists.

if exist(filename, 'file')
    delete(filename)
end

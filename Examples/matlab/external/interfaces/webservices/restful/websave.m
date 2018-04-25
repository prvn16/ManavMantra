function filename = websave(filename, url, varargin)
%WEBSAVE Save content from RESTful web service to file
%
%   Syntax
%   ------
%   OUTFILENAME = WEBSAVE(FILENAME,URL)
%   OUTFILENAME = WEBSAVE(FILENAME,URL,QueryName1,QueryValue1, ...)
%   OUTFILENAME = WEBSAVE(__,OPTIONS)
%
%   Description
%   ------------
%   OUTFILENAME = WEBSAVE(FILENAME,URL) saves content from the web service
%   specified by the string URL to the file FILENAME. If URL indicates a
%   file, and FILENAME does not contain the same extension, then the
%   extension of URL is appended to FILENAME. WEBSAVE returns the resultant
%   name in the string OUTFILENAME, which also includes the full path to
%   the file. WEBSAVE sets HTTP request parameters with the default
%   property values of WEBOPTIONS and uses the HTTP GET method to read
%   content from URL.
%
%   OUTFILENAME = WEBSAVE(FILENAME,URL,QueryName1,QueryValue1, ...) appends
%   additional RESTful web service query parameters, specified by QueryName1,
%   QueryValue1, ..., to URL. These name,value pair arguments set query
%   parameters in an HTTP GET operation. The parameters supported by a web
%   service are defined in the service's documentation. WEBSAVE adds parameters
%   to URL using the "&name=value" construct. However, if URL does not contain a
%   "?" character, then WEBSAVE adds the first name, value pair as
%   "?name=value". WEBSAVE still adds all following parameters as "&name=value".
%   Numeric and logical values are encoded as strings using NUM2STR. Nonscalar
%   values are encoded as specified by the default ArrayFormat property of WEBOPTIONS.
%
%   OUTFILENAME = WEBSAVE(__,OPTIONS) sets HTTP request parameters with the property
%   values of the scalar WEBOPTIONS object OPTIONS. Set the RequestMethod
%   property of OPTIONS to 'post' or some other method if you need to use a
%   method other than GET when reading data from a RESTful web service.
%   Changing the RequestMethod does not affect where the query parameters are
%   placed: they always are appended to the URL.  To place parameters in the
%   body of the message, use WEBWRITE.
%
%   Input Arguments
%   ---------------
%
%   Name          Description                             Data Type
%   ----      --------------------                        ---------
%   FILENAME  
%         Name of file to save content.                   string
%
%   URL   Web address of content including the            string
%         transfer protocol, http or https. 
%         The URL is automatically encoded.
%
%   QueryName
%         Name of additional web service parameter        string
%         to append to URL.
%
%   QueryValue 
%         Value of additional web service parameter       string; vector of
%         to append to URL.  If you specify a datetime    numeric, logical
%         you must specify its Format property as         or datetime; 2-D 
%         expected by the web service.  If it is a        array of char; or
%         non-scalar vector or cell vector, or char       cell array containing
%         array with more than one row, the value is      strings or numeric,
%         processed according to the ArrayFormat property logical or datetime
%         of WEBOPTIONS.                                  scalars
%
%   OPTIONS 
%         Other options used to connect to web            scalar WEBOPTIONS 
%         service.                                        object
%
%   % Example 1
%   % ---------
%   % Download the HTML page on the MATLAB(R) Central File Exchange that
%   % lists submissions for sensor-data-acquisition to a file.
%   url = 'https://www.mathworks.com/matlabcentral/fileexchange';
%   searchTerm = 'sensor-data-acquisition';
%   filename = [searchTerm '.html'];
%   websave(filename,url,'term',searchTerm);
%
%   See also DATETIME, WEBOPTIONS, WEBREAD, WEBWRITE

% Copyright 2014-2017 The MathWorks, Inc.
   
% Validate filename.
if isstring(filename)
    filename = char(filename);
end
validateattributes(filename, {'char'}, {'scalartext'}, ...
    mfilename, 'FILENAME');
filename = filename(:)';

% Parse the inputs.
[queryParams, options] = parseInputs(mfilename, varargin);

% Encode inputs.
[url, options] = encodeInputs(url, queryParams, options);

% Open the HTTP connection and obtain the connection content type.
connection = openHTTPConnection(url, options, '');

% Append an extension to filename, if needed.
filename = appendUrlExtension(url, filename, connection.ContentType);

% Ensure that the file can be written and return full path to the file.
filename = validateFileAccess(filename);

% Copy the content from the web service to the file.
copyContentToFile(connection, filename);
  
%--------------------------------------------------------------------------

function filename = appendUrlExtension(url, filename, contentType)
% Append the extension of URL, if URL does not contain ? and the filename
% does not match the URL extension. Add .html if content type is HTML and
% the extension is not added.

if ~contains(url, '?')
    % There are no URL query parameters, obtain the extension of URL.
    [~, ~, urlExt] = fileparts(url);
    
    % Obtain the extension of the file.
    [~,~,fileExt] = fileparts(filename);
    
    % Determine if content type is HTML.
    if contains(contentType, 'html')
        % Content type is HTML. Preserve .htm or .html if provided,
        % otherwise add .html
        htmlExt =  {'.htm','.html'};
        index = strncmpi(fileExt, htmlExt, length(fileExt));
        if ~any(index) || isempty(fileExt)
            % The filename does not have an extension.
            index = strncmp(urlExt, htmlExt, length(urlExt));
            if any(index) && isscalar(find(index))
                urlExt = [htmlExt{index}];
            else
                urlExt = '.html';
            end
            filename = [filename urlExt];
        end
                
    elseif ~isempty(urlExt) && isempty(fileExt)
        % Content is not HTML.
        % Append extension of the URL if filename doesn't have an extension
        filename = [filename urlExt];
    end
end

%--------------------------------------------------------------------------

function filename = validateFileAccess(filename)
% Ensure that the file is writable and return full path name.

if exist(filename,'file')
    fileIsNew = false;
else
    fileIsNew = true;
end

% Validate the file can be opened. This results in a file on the disk.
fid = fopen(filename,'w');
if fid == -1
    e = MException(message('MATLAB:webservices:InvalidFilename',filename));
    throwAsCaller(e);
end
fclose(fid);

% Use fopen to obtain full path to the file and to translate ~ or ~username
% on Unix.
fid = fopen(filename);
filename = fopen(fid);
fclose(fid);

if fileIsNew && exist(filename,'file')
    % Remove this file in case an error is issued later. 
    delete(filename)
end

function varargout = ...
    readContentFromFile(filename, charSet, urlContentType, options, url)
%readContentFromFile Read content from file
%
%   Syntax
%   ------
%   VARARGOUT = readContentFromFile(FILENAME, charSet, urlContentType, OPTIONS, URL)
%
%   Description
%   -----------
%   VARARGOUT = readContentFromFile(FILENAME, charSet, urlContentType,
%   OPTIONS, URL) reads the content from FILENAME, using a reader selected
%   by the values from urlContentType and OPTIONS. charSet is applied when
%   reading text data from a file. URL is a string indicating the URL from
%   which the content was read and is used in constructing error messages.
%
%   See also WEBREAD, WEBSAVE

% Copyright 2014 The MathWorks, Inc.

% Determine reader from content type.
reader = contentTypeReader(charSet, urlContentType, options);

% Read data from file.
try
    [varargout{1:nargout}] = reader(filename);
catch e
    error(message('MATLAB:webservices:ContentTypeReaderError', ...
        e.message, url, 'WEBSAVE'));
end
       
%--------------------------------------------------------------------------

function reader = contentTypeReader(charSet, urlContentType, options)
% Determine the reader function handle based on the content type.

if isa(options.ContentReader, 'function_handle')
    reader = options.ContentReader;
else
    % Determine content type.
    if strcmp(options.ContentType, 'auto')
        % Content type is 'auto', select the content type from the URL
        % connection.
        contentType = urlContentType;
        if strcmp(contentType, 'xmldom')
            % 'text' is the default content type value for XML content.
            contentType = 'text';
        end
    else
        % Content type is not auto, select the content type from options.
        contentType = options.ContentType;
    end
    
    % Determine reader based on content type.
    switch contentType
        case 'image'
            reader = @imread;
        case 'table'
            reader = @tableread;
        case 'audio'
            reader = @audioread;
        case 'xmldom'
            reader = @xmlread;
        case 'text'
            reader = @(x) fileread(x, '*char', charSet);
        otherwise
            % This line should never be reached. JSON and binary are not
            % read by this file. Read as binary for this non-reachable
            % condition.
            charSet = '';
            reader = @(x) fileread(x, 'uint8=>uint8', charSet);
    end
end

%--------------------------------------------------------------------------

function data = fileread(filename, precision, charSet)
% Read the file with a given precision and charSet. Return a row vector.

if isempty(charSet)
    fid = fopen(filename, 'r');
else
    fid = fopen(filename, 'r', 'native', charSet);
end

data = fread(fid, precision)';
fclose(fid);

%--------------------------------------------------------------------------

function data = tableread(filename)
% Read a spreadsheet or CSV file using readtable. 

% Some files do not have valid entries for the variable names. For example,
% a name may contain a space (' ') character. For that case,
% ReadVariableNames needs to be false. For others, the entries are correct
% and the variable names should be read.

% Turn off the ModifiedAndSavedVarnames warning.
wstate = warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
wobj = onCleanup(@() warning(wstate));

try
    data = readtable(filename);
catch e %#ok<NASGU>
    % An error occured. Try setting ReadVariableNames to false.
    data = readtable(filename, 'ReadVariableNames', false);
end

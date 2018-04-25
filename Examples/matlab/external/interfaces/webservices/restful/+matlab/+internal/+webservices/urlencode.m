function url = urlencode(url, options, varargin)
%matlab.internal.webservices.URLENCODE Return a string that incorporates the URL
%and query parameter name-value pairs, properly encoded.
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/restful. Its behavior
%   may change, or the function itself may be removed in a future release.
%
%   Syntax
%   ------
%   encodedURL = matlab.internal.webservices.URLENCODE(URL) 
%   encodedURL = matlab.internal.webservices.URLENCODE(__, options, queryName1,
%      queryValue1, ...)
%
%   Description
%   ------------
%   encodedURL = matlab.internal.webservices.URLENCODE(URL) encodes the URL
%   specified by URI (string, char vector or matlab.net.URI).
%
%   encodedURL = matlab.internal.webservices.URLENCODE(URL, OPTIONS, queryName1,
%   queryValue1, ...) adds additional URL parameters, specified by the name
%   value pairs, queryName1, queryValue1, to the URL. These parameters are
%   defined in the Web service documentation and consist of a name and
%   value. The parameters are added to the URL using the "&name=value"
%   construct or if it is the first pair, and the URL does not contain a
%   "?" character, then it is added as "?name=value". The name, value pairs
%   are encoded prior to adding to the URL. Numeric values are converted by num2str
%   before encoding.
%
%   OPTIONS is a weboptions object, used to specify formatting options
%      for query parameters.  If empty a default weboptions is used.
%
%   Example
%   -------
%   URL = 'http://www.datasciencetoolkit.org/maps/api/geocode/json';
%   address = '3 Apple Hill Road, Natick, MA, 01760';
%   encodedURL = matlab.internal.webservices.urlencode( ...
%      URL, 'address', address)
%
%   See also WEBREAD, WEBSAVE, WEBWRITE

% Copyright 2014-2016 The MathWorks, Inc.

% Validate URL.  This returns a matlab.net.URI
uri = validateURL(url);
url = char(uri);

if nargin > 1
    % Encode the input query parameters, if present, and add to URL.
    % TBD This logic should use matlab.net.QueryParameter
    queryParams = varargin;
    if ~isempty(queryParams)
        url = encodeNameValueQueryParameters(url, options, queryParams);
    end
end

%--------------------------------------------------------------------------

function uri = validateURL(uri)
% Validate URL input and return a URI.  If it's not a URI, then construct a URI from it.  
% Accepts URI, string or char

if isa(uri, 'matlab.net.URI') 
    validateattributes(uri, {'matlab.net.URI'}, {'scalar'}, mfilename, 'URL');
else
    if isstring(uri)
        validateattributes(uri, {'string'}, {'scalar'}, mfilename, 'URL');
    else
        % string or URI don't come in here, but we need to mention them in message            
        validateattributes(uri, {'char' 'string' 'matlab.net.URI'}, ...
            {'nonempty', 'vector'}, mfilename, 'URL');
        % reshape to row
        uri = reshape(uri,1,[]);
    end
    if isstring(uri) || ischar(uri)
        % If string or char, make a URI object out of it
        try
            % In 17b, g1569018 in URI was fixed that incorrectly encoded the query.  To
            % maintain legacy (16b) behavior for RESTful functions, if the input has a
            % query, we need to encode it specially.
            addr = regexp(uri,'^.*?([#?]|$)','match','once'); % everything up to/including first ? or #
            query = regexp(uri,'[#?].*$','match','once');     % whole query including ? or #
            if ~isempty(query) && (~isstring(query) || ~ismissing(query)) && query ~= ""
                % It has a query.  Encode the query using 16b rules
                query = extractAfter(query,1);
                query = matlab.net.internal.urlencode(query, '+!#/?=&%:,', true);
                uri = strcat(addr,query);
                % Append the encoded query to the address. 
            end
            % The 'literal' specifier prevents encoding the address.  The query is never
            % encoded (as of g1569018) so it stays whatever we set it to above.
            uri = matlab.net.URI(uri, 'literal');
        catch e
            throwAsCaller(e);
        end
    end
end

% Validate the protocol.
schemes = {'http', 'https'};
if isempty(uri.Scheme) || ~any(strcmpi(uri.Scheme, schemes))
    protocols = strcat(schemes,'://');
    scheme = uri.Scheme;
    if isempty(scheme)
        scheme = "";
    end
    error(message('MATLAB:webservices:ExpectedProtocol', ...
        char(scheme), char(uri), protocols{:}))
end

% Verify that a host has been provided.
if isempty(uri.Host) || uri.Host == ''
    error(message('MATLAB:webservices:ExpectedHostname', ...
        char(uri), 'https://www.mathworks.com'))
end

%--------------------------------------------------------------------------

function url = encodeNameValueQueryParameters(url, options, queryParams)
% Encode Name,Value query parameters.

encodedValues = matlab.internal.webservices.formencode(options, queryParams);

% Determine the required ending for the URL.
separator = determineURLEndCharacter(url);

% Append encoded values to URL.
url = [url separator encodedValues];

%--------------------------------------------------------------------------

function separator = determineURLEndCharacter(url)
% If required (url points to a RESTful Web service), ensure a '?' character
% is at the end of url. If the URL has RESTful parameters already
% specified (via a ? in the URL), then do not add a '?' character at the
% end.

indexQ = strfind(url, '?');
if isempty(indexQ)
    % URL does not contain any ? characters.
    % Append '?' to end of url.
    separator = '?';
elseif indexQ(end) == length(url) || strcmp(url(end),'&')
    % URL contains a '?' at the end of the URL.
    separator = '';
else
    % URL contains ? characters.
    % Append '&' to end of URL.
    separator = '&';
end


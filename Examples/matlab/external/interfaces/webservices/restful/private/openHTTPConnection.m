function connection = openHTTPConnection(url, options, postData)
%openHTTPConnection Open HTTP connection
%
%   Syntax
%   ------
%   CONNECTION = openHTTPConnection(URL, OPTIONS, postData)
%
%   Description
%   -----------
%   CONNECTION = openHTTPConnection(URL, OPTIONS, postData) constructs a
%   matlab.internal.webservices.HTTPConnector object, sets the PostData
%   property to the value of the string postData, and opens the connection.
%
%   See also WEBREAD, WEBSAVE, WEBWRITE

% Copyright 2014 The MathWorks, Inc.

% Construct an HTTPConnector object and open the connection. Throw any
% error as caller since we are using an internal class.
try
    if strcmpi(options.MediaType, 'auto')
        % if MediaType still remains auto, set it to the default for consistency with
        % legacy behavior
        options.MediaType = 'application/x-www-form-urlencoded';
    end

    connection = matlab.internal.webservices.HTTPConnector(url, options);
    connection.PostData = postData;
    openConnection(connection);
catch e
    throwAsCaller(e);
end

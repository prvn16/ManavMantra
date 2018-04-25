function [url, options] = encodeInputs(url, queryParams, options)
%encodeInputs Encode inputs for webread and websave
%
%   Syntax
%   ------
%   [URL, OPTIONS] = encodeInputs(URL, queryParams, OPTIONS)
%
%   Description
%   -----------
%   [URL, OPTIONS] = encodeInputs(url, queryParams, OPTIONS)
%   encodes the URL and the queryParams in URL.
%   If options.RequestMethod is 'auto', set it to 'get'.
%
%   See also WEBREAD, WEBSAVE

% Copyright 2014-2016 The MathWorks, Inc.

try
    if any(strcmpi(options.RequestMethod, {'get','auto'}))
        options.RequestMethod = 'get';
    end
    url = matlab.internal.webservices.urlencode(url, options, queryParams{:});
catch e
    throwAsCaller(e)
end

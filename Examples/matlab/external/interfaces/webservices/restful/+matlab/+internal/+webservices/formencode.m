function encodedString = formencode(options, pairs, queryName, queryValue)
%matlab.internal.webservices.FORMENCODE Encode name, value pairs
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/restful. Its behavior
%   may change, or the function itself may be removed in a future release.
%
%   Syntax
%   ------
%   encodedString = matlab.internal.webservices.formencode(options, pairs) 
%   encodedString = matlab.internal.webservices.formencode(options, ...
%          pairs, queryName, queryValue)
%
%   Description
%   ------------
%   encodedString = matlab.internal.webservices.formencode(options,PAIRS)
%   encodes the pairs in the cell array, PAIRS. PAIRS contains a set of
%   name, value pairs and returns the encoded string in encodedString. The
%   string consists of "name=value" or if multiple pairs are present, the
%   pairs are separated by the character "&".  
%
%   If a value is an array (or for strings, a cell array) it is encoded according to
%   options.ArrayFormat.  See the description of this parameter in urlencode.
%
%   options is an weboptions object, used to determine MediaType and other
%       encoding information.  It must be specified, but if empty, a default 
%       weboptions is used.
%
%   encodedString = matlab.internal.webservices.formencode(__,queryName,
%   queryValue) uses the strings queryName and queryValue for constructing
%   error messages.
%
%   Example
%   -------
%   address = '3 Apple Hill Road, Natick, MA, 01760';
%   encodedString = matlab.internal.webservices.formencode({'address', address})
%
%   See also WEBREAD, WEBSAVE, WEBWRITE, matlab.internal.webservices.urlencode

% Copyright 2014-2016 The MathWorks, Inc.
        
    if isempty(options)
        % when coming here from webread, websave, etc. options will always be set
        options = weboptions;
    end
    encodedMediaType = "application/x-www-form-urlencoded";
    if ~any(strcmpi(options.MediaType,[encodedMediaType "auto"]))
        options = 'options.MediaType';
        type = 'application/x-www-form-urlencoded';
        error(message('MATLAB:webservices:ExpectedFormEncode', ...
            options,type,options,type));
    end

    if nargin < 3
        queryName = 'queryName';
        queryValue = 'queryValue';
    end

    if rem(length(pairs),2)
        error(message('MATLAB:webservices:ExpectedPairs',queryName,queryValue))
    end

    format = matlab.net.ArrayFormat.(lower(options.ArrayFormat));

    % Strip leading ? from first parameter name and leading & from all parameter names
    % This errors out if that would leave any name empty.  We allow these chars in other
    % parts of the name -- we'll just encode them.

    % This code is required to maintain original formencode behavior (before we
    % switched to using QueryParameter) which allows ? and & in the front of a
    % name.  However we don't strip leading '=' like we did before, as there's no
    % reason to expect the user might do this unless he really intended to have
    % that character in a name.
    if ~isempty(pairs) && (ischar(pairs{1}) || isstring(pairs{1})) && string(pairs{1}).startsWith('?')
        pairs{1} = strip(pairs{1}, '?', queryName);
        first = 3;
    else
        first = 1;
    end

    pairs(first:2:end) = cellfun(@(p)strip(p,'&',queryName), pairs(first:2:end), ...
                                 'UniformOutput', false);

    % if something is invalid about a name or value, QueryParameter will throw an error
    params = matlab.net.QueryParameter(pairs{:}, format);
    encodedString = char(params);
end

%--------------------------------------------------------------------------

function name = strip(name, ch, queryName)
% Strip ch from front of name.  If that leaves it empty, throw error.  Ignore
% name if empty, empty string, or not a string or char vector.
    if isstring(name)
        name = char(name);
    end
    if ischar(name) && ~isempty(name) && name(1) == ch
        if isscalar(name)
            error(message('MATLAB:webservices:UrlParamContainsSeparator', ...
                          queryName, '''&'', ''?'''));
        end
        name = name(2:end);
    end
end


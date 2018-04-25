function token = quoteToken(token, delims)
% Return the token as a string, quoted if necessary based on the standard set of
% characters not allowed in a token, plus any additional characters in delims.  Also
% add escape characters within quotes where necessary.
%  
% delims is optional

% Copyright 2015-2016 The MathWorks, Inc.

    % Check for special characters to see if we need to quote it.  These chars are
    % from the list in 3.2.6 of RFC7230 not allowed in a token.
    token = string(token);
    match = '[^' + matlab.net.http.HeaderField.TokenChars + ']';
    if nargin >= 2 && ~isempty(char(delims))
        % To the standard list, also add any sequences in delims.
        % The additional delims to check for may contain regexp
        % metacharacters, so escape them.
        delims = matlab.net.internal.getSafeRegexp(delims);
        % form new regexp to check for additional delims, OR'ed together
        match = match + '|' + strjoin(delims, '|');
    end
    if ~isempty(regexp(token, match, 'ONCE'))
        % token has a special character or delim, so escape \ and " and then
        % quote it
        token = '"' + regexprep(token, '[\\"]', '\\$&') + '"';
    end
end


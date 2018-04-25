function tf = partialMatchString(str, options, N)
% PARTIALMATCHSTRING  Partial matching for string options.

%   Copyright 2017 The MathWorks, Inc.

    if nargin < 3
        N = 1;
    end
    % Possible options to match should be string/char/cellstr
    assert(isstring(options) || ischar(options) || iscellstr(options))
    if ~isstring(options)
        options = string(options);
    end
    % String to match must be scalar text
    if ~((ischar(str) && isrow(str)) || (isstring(str) && isscalar(str)))
        tf = false(size(options));
    else
        tf = strncmpi(str, options, max(N, strlength(str)));
        % No duplicate matches
        tf = tf & (nnz(tf) == 1);
    end
end

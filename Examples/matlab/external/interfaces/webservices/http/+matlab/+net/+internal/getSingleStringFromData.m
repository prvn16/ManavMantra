function [str, len] = getSingleStringFromData(str)
%getSingleStringFromData returns a single string or char vector created from
%  str, and its length in characters
%    str is a char array; concatenate all the chars row-wise; return char
%      vector
%    str is a cellstr; concatenate all the strings row-wise, return char
%      vector
%    str is a string array; concatenate all the strings row-wise, return
%      scalar string

% Copyright 2015-2016 The MathWorks, Inc

    str = reshape(str', 1, []);
    if isstring(str) || iscellstr(str)
        if ~isscalar(str)
            str = strjoin(str,'');
        end
        if ischar(str)
            len = length(str);
        else
            len = strlength(str);
        end
    else
        assert(ischar(str));
        len = length(str);
    end
end


function out = strtrim(in)
%STRTRIM Remove leading and trailing whitespace.
%   S = STRTRIM(M) removes leading and trailing whitespace from each string
%   in M. M must be a tall array of strings or a tall cell array of char
%   vectors.
%
%   See also: strtrim, tall/deblank.

%   Copyright 2015-2016 The MathWorks, Inc.

in = tall.validateType(in, mfilename, {'string', 'cellstr'}, 1);

% Safe to use ELEMENTFUN since we only handle arrays of strings or cellstr
out = elementfun(@strtrim, in);
out.Adaptor = in.Adaptor;
end

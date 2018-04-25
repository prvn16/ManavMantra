function out = deblank(in)
%DEBLANK Remove trailing blanks.
%   S = DEBLANK(M) removes trailing whitespace from each string in M. M
%   must be a tall array of strings or a tall cell array of char vectors.
%
%   See also: deblank, tall/strtrim.

%   Copyright 2015-2016 The MathWorks, Inc.

in = tall.validateType(in, mfilename, {'string', 'cellstr'}, 1);

% Safe to use ELEMENTFUN since we only handle arrays of strings or cellstr.
out = elementfun(@deblank, in);
% Output is same type and size as input.
out.Adaptor = in.Adaptor;
end

function s = pad(m, varargin)
%PAD Inserts leading and trailing characters.
%   S = PAD(M)
%   S = PAD(M, SIDE)
%   S = PAD(M, WIDTH)
%   S = PAD(M, WIDTH, SIDE)
%   S = PAD(M, WIDTH, SIDE, PadCharacter)
%
%   When WIDTH is not specified a full pass through over the elements of M
%   is used to determine it.
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,4);

% First input must be tall string.
if ~istall(m)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
m = tall.validateType(m, mfilename, {'string'}, 1);

% Remaining inputs must not be tall
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% Let PAD parse the inputs for us so that we get identical errors
try
    pad("", varargin{:});
catch err
    throw(err)
end

% If the width is not specified, we have to do a pass through the data to
% discover it. If exactly two args, always assume the second is width.
if (nargin>=2) && isnumeric(varargin{1})
    width = varargin{1};
    args = varargin(2:end);
else
    % No width. Do a reduction to scalar across the data to discover it.
    width = aggregatefun(@iGetMaxLength, @max, m);
    args = varargin;
end
% Now that we have the width, we can just work on each element separately
s = elementfun(@(x,w) pad(x,w,args{:}), m, width);
% width must end up scalar, so we know the size and type of the output must be
% the same as the size and type of m.
s.Adaptor = m.Adaptor;
end

function w = iGetMaxLength(str)
% Helper to get the maximum width of an array of strings, or zero if empty
if isempty(str)
    w = 0;
else
    w = max(strlength(str(:)));
end
end

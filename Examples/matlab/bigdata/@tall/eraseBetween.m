function out = eraseBetween(in,startStr,endStr, varargin)
%ERASEBETWEEN Remove segments from string elements.
%   S = ERASEBETWEEN(STR, START, END)
%   S = ERASEBETWEEN(..., 'Boundaries', B)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(3,5);

% First input must be tall string. Trailing arguments must not be.
tall.checkIsTall( upper(mfilename), 1, in );
in = tall.validateType(in, mfilename, {'string'}, 1);
tall.checkNotTall(upper(mfilename), 3, varargin{:});

% Treat all inputs element-wise, wrapping char arrays if used
startStr = wrapCharInput(startStr);
endStr = wrapCharInput(endStr);
out = elementfun(@(a,b,c) eraseBetween(a,b,c,varargin{:}), in, startStr, endStr);

% Output is same size and type as first input (can be cellstr or string)
out.Adaptor = in.Adaptor;

end

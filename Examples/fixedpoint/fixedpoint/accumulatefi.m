function c = accumulatefi(a,b,mode,varargin)
% ACCUMULATEFI(a,b,mode,...) Undocumented internal function.

% Copyright 2011-2013 The MathWorks, Inc.

switch nargin
    case 3 % only a & b are provided, roundmode & overflow mode default to 'floor & 'wrap'
        roundmode = 'floor';
        overflowmode = 'wrap';
    case 4 % a, b, roundmode provided, overflow mode defaults to 'wrap'
        roundmode = varargin{1};
        overflowmode = 'wrap';
    case 5 % a, b, roundmode and overflow mode provided
        roundmode = varargin{1};
        overflowmode = varargin{2};
end

% Call the builtin embedded.fi.accumulatepos or embedded.fi.accumulateneg
if isequal(mode,'pos')
   c = embedded.fi.accumulatepos(a,b,roundmode,overflowmode);
else
   c = embedded.fi.accumulateneg(a,b,roundmode,overflowmode);
end

c.fimathislocal = false;

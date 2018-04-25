function out = cumprod(in, varargin)
%CUMPROD Cumulative product of elements of a tall array.
%   Y = CUMPROD(X)
%   Y = CUMPROD(X,DIM)
%   Y = CUMPROD(___,NANFLAG)
%
%   Limitations:
%   1) The 'reverse' direction is not supported.
%   2) Integer overflow behavior for the types int8, int16, int32 and int64
%      not guaranteed to match non-tall result.
%
%   See also CUMPROD, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

% Definitions for the common code
fcnStruct = struct( ...
    'Name', mfilename, ...
    'TallReduceFcn', @(x,varargin) prod(x, 1, varargin{:}, 'native'), ...
    'TallAccumFcn', @(x,varargin) cumprod(x, 1, varargin{:}), ...
    'SliceAccumFcn', @cumprod, ...
    'SliceAdjustFcn', @iTimes, ...
    'TypeRule', 'preserveLogicalCharToDouble', ...
    'DefaultNaNFlag', 'includenan', ...
    'ForcePropagateDerivedNaNs', true );

% Use the shared cumfun implementation, but hide the error stack.
try
    out = cumfunCommon(fcnStruct, in, varargin{:});
catch err
    throw(err);
end


function out = iTimes(x, y, varargin)
% When combining partial results, always include nans (i.e. ignore nanFlag)
out = times(x,y);


function out = cumsum(in, varargin)
%CUMSUM Cumulative sum of elements of a tall array.
%   Y = CUMSUM(X)
%   Y = CUMSUM(X,DIM)
%   Y = CUMSUM(___,NANFLAG)
%
%   Limitations:
%   The 'reverse' direction is not supported.
%
%   See also CUMSUM, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

% Definitions for the common code
fcnStruct = struct( ...
    'Name', mfilename, ...
    'TallReduceFcn', @iSum, ...
    'TallAccumFcn', @(x, varargin) cumsum(x, 1, varargin{:}), ...
    'SliceAccumFcn', @cumsum, ...
    'SliceAdjustFcn', @iPlus, ...
    'TypeRule', 'preserveLogicalCharToDouble', ...
    'DefaultNaNFlag', 'includenan', ...
    'ForcePropagateDerivedNaNs', true );

% Use the shared cumfun implementation, but hide the error stack.
try
    out = cumfunCommon(fcnStruct, in, varargin{:});
catch err
    throw(err);
end


function out = iSum(x, varargin)
if isinteger(x)
    % Ensure that integer types are propagated 
    out = sum(x, 1, varargin{:}, 'native');
else
    % Default type propagation rules apply
    out = sum(x, 1, varargin{:});
end


function out = iPlus(x, y, varargin)
% When combining partial results, always include nans (i.e. ignore nanFlag)
out = plus(x, y);

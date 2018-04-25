function out = cummin(in, varargin)
%CUMMIN Cumulative smallest component of a tall array.
%   Y = CUMMIN(X)
%   Y = CUMMIN(X,DIM)
%   Y = CUMMIN(___,NANFLAG)
%
%   Limitations:
%   The 'reverse' direction is not supported.
%
%   See also CUMMIN, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

% Definitions for the common code
fcnStruct = struct( ...
    'Name', mfilename, ...
    'TallReduceFcn', @(x,varargin) min(x, [], 1, varargin{:}), ...
    'TallAccumFcn', @(x,varargin) cummin(x, 1, varargin{:}), ...
    'SliceAccumFcn', @cummin, ...
    'SliceAdjustFcn', @min, ...
    'TypeRule', 'preserve', ...
    'DefaultNaNFlag', 'omitnan', ...
    'ForcePropagateDerivedNaNs', false );

% Use the shared cumfun implementation, but hide the error stack.
try
    out = cumfunCommon(fcnStruct, in, varargin{:});
catch err
    throw(err);
end

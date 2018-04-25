function out = cummax(in, varargin)
%CUMMAX Cumulative largest component of a tall array.
%   Y = CUMMAX(X)
%   Y = CUMMAX(X,DIM)
%   Y = CUMMAX(___,NANFLAG)
%
%   Limitations:
%   The 'reverse' direction is not supported.
%
%   See also CUMMAX, TALL.

%   Copyright 2016-2017 The MathWorks, Inc.

% Definitions for the common code
fcnStruct = struct( ...
    'Name', mfilename, ...
    'TallReduceFcn', @(x,varargin) max(x, [], 1, varargin{:}), ...
    'TallAccumFcn', @(x,varargin) cummax(x, 1, varargin{:}), ...
    'SliceAccumFcn', @cummax, ...
    'SliceAdjustFcn', @max, ...
    'TypeRule', 'preserve', ...
    'DefaultNaNFlag', 'omitnan', ...
    'ForcePropagateDerivedNaNs', false );

% Use the shared cumfun implementation, but hide the error stack.
try
    out = cumfunCommon(fcnStruct, in, varargin{:});
catch err
    throw(err);
end

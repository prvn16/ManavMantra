function varargout = arrayfun(fcn, varargin)
%ARRAYFUN Apply a function to each element of a tall array.
%   TX = ARRAYFUN(FUN,TA)
%   [TX1,TX2,...] = ARRAYFUN(FUN,TA1,TA2,...)
%   [TX1,...] = ARRAYFUN(FUN,TA1,...,'UniformOutput',TF)
%
%   Limitations:
%   1) FUN must not rely on any state such as PERSISTENT data.
%   2) The 'ErrorHandler' argument is not supported.
%   3) In UniformOutput mode, outputs from FUN must be numeric, logical, char, or
%      cell.
%
%   See also arrayfun, tall.

% Copyright 2016-2017 The MathWorks, Inc.

try
    [varargout{1:max(1, nargout)}] = funfunCommon(@arrayfun, fcn, {}, varargin{:});
catch E
    throw(E);
end
end

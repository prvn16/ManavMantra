function varargout = cellfun(fcn, varargin)
%CELLFUN Apply a function to each cell of a tall cell array.
%   TA = CELLFUN(FUN,TC)
%   [TA,TB] = CELLFUN(FUN,TC1,TC2,...)
%   [TA,...] = CELLFUN(FUN,TC,...,'UniformOutput',TF)
%
%   Limitations:
%   1) FUN must be a function handle.
%   2) FUN must not rely on any state such as PERSISTENT data.
%   3) The 'ErrorHandler' argument is not supported.
%   4) In UniformOutput mode, outputs from FUN must be numeric, logical, char, or
%      cell.
%
%   See also cellfun, tall.

% Copyright 2016 The MathWorks, Inc.

try
    [varargout{1:max(1, nargout)}] = funfunCommon(@cellfun, fcn, {'cell'}, varargin{:});
catch E
    throw(E);
end
end

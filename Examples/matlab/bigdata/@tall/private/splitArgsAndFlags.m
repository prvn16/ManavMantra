function [argsCell, flagsCell] = splitArgsAndFlags(varargin)
%splitArgsAndFlags Split arguments into actual arguments and trailing flags
%   Appropriate only for functions which take optional trailing flags
%   such as SUM, MEAN etc.

% Copyright 2015-2017 The MathWorks, Inc.

lastNonCharPosition = find(~cellfun(@isNonTallScalarString, varargin), 1, 'last');
if isempty(lastNonCharPosition) && nargin > 0 && isNonTallScalarString(varargin{1})
    argsCell = cell(1, 0);
    flagsCell = varargin;
else
    argsCell = varargin(1:lastNonCharPosition);
    flagsCell = varargin((1 + lastNonCharPosition):end);
end
end

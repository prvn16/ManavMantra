function h = horizontalline(fun, varargin)
% HORIZONTALLINE  Creates a horizontal line from a constant function.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin < 1
    error(message('MATLAB:horizontalline:NeedsMoreArgs'));
end

h = matlab.graphics.chart.primitive.ConstantLine(varargin{:});
h.Value = fun;

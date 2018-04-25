function h = verticalline(fun, varargin)
% VERTICALLINE  Creates a vertical straight line from a constant function.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin < 1
    error(message('MATLAB:verticalline:NeedsMoreArgs'));
end

h = matlab.graphics.chart.primitive.ConstantLine(varargin{:}); 
h.Value = fun;

changedependvar(h,'x');
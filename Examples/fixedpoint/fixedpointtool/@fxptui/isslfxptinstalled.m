function [b, errstr, errid] = isslfxptinstalled
%ISSLFXPTINSTALLED   Returns true if the Fixed-Point Designer is installed.

%   Author(s): P. Costa
%   Copyright 2007-2012 The MathWorks, Inc.

b = builtin('license','test','Fixed_Point_Toolbox') && ~isempty(ver('fixedpoint'));

if b
    errstr = '';
    errid  = '';
else
    errstr = sprintf('%s\n%s', 'Fixed-Point Designer is not available.', ...
        'Make sure that it is installed and that a license is available.');
    errid  = 'noSLFxpt';
end

% [EOF]

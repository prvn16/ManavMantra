function str = propertyDisplay(propertyName, mockClassName, value)
% This function is undocumented and may change in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.mock.internal.getOneLineSummary;

str = getString(message('MATLAB:mock:display:MockObjectSummary', mockClassName)) + "." + propertyName;
if nargin > 2
    str = str + " = " + getOneLineSummary(value);
end
end


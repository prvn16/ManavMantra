function str = methodCallDisplay(className, methodName, static, inputs)
% This function is undocumented and may change in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.mock.internal.getOneLineSummary;

inputsDisplay = cellfun(@getOneLineSummary, inputs, 'UniformOutput',false);
str = methodName + "(" + strjoin([string.empty, inputsDisplay{:}], ", ") + ")";

if static
    str = getString(message('MATLAB:mock:display:MockObjectSummary', className)) + "." + str;
end
end

% LocalWords:  strjoin

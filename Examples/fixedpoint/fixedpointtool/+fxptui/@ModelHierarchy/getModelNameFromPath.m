function modelName = getModelNameFromPath(~, sysName)
% Given a subsystems full name, return its top model name
% g1517433, g1516810

% Copyright 2017 The MathWorks, Inc.

sysName = strsplit(sysName, '/');
modelName = sysName{1};
end
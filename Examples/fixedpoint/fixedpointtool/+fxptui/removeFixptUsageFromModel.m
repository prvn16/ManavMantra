function b = removeFixptUsageFromModel(model)
% REMOVEFIXPTLICENSEUSAGE Removes the need for  Fixed-Point License by overriding the model with
% doubles and removing Fixed-Point instrumentation across the model
% hierarchy.

% Copyright 2016 The MathWorks, Inc.

% Need a return value for "fix-it" diagnostic.
b = '';

fxptui.setDTOValueOnModel(model, 'Double');
fxptui.removeMMOFromModel(model);
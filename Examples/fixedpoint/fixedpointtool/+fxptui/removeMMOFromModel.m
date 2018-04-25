function b = removeMMOFromModel(model)
% REMOVEMMOFROMMODEL Removes the need for  Fixed-Point License by
% removing Fixed-Point instrumentation across the model hierarchy.

% Copyright 2016 The MathWorks, Inc.

% Need a return value for "fix-it" diagnostic.
b = '';

% Get all the references from the model
try
    [refMdls, ~] = find_mdlrefs(model);
catch
    % Not all references are on path. Instead of throwing an error, just
    % turn off settings on the model.
    refMdls = {model};
end
for i = 1:numel(refMdls)
    set_param(refMdls{i},'MinMaxOverflowLogging','ForceOff');
end
end
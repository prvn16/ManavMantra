function b = setDTOValueOnModel(model, dtoValue)
% SETDTOVALUEONMODEL Sets the data type override parameter on the
% model hierarchy to the specified value.

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
    set_param(refMdls{i},'DataTypeOverride',dtoValue);
    set_param(refMdls{i},'DataTypeOverrideAppliesTo','AllNumericTypes');
end
end
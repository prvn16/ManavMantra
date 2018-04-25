% Copyright 2016 The MathWorks, Inc.

function first_param_string_idx = findFirstParamString(args, method_arg_idx)
% Find the index of the first parameter string.  It will be the first
% string argument following the method argument.

if isempty(method_arg_idx)
    method_arg_idx = 0;
end

is_class = cellfun('isclass', args(method_arg_idx+1:end), 'char');
first_param_string_idx = find(is_class, 1) + method_arg_idx;
end

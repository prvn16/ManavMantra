function parfor_nested_for_range_step_check(varname, step)
% Copyright 2017 The MathWorks, Inc.
% This function is undocumented and reserved for internal use. It may be
% removed in a future release.
%
% The step of nested for-loops used to index sliced variables must
% evaluate to a scalar integer
if (~isscalar(step) || ~isnumeric(step) || ~isreal(step) ||...
    ~isfinite(step) || step ~= round(step))

    error(message('MATLAB:parfor:nested_for_range_step_check',... 
          varname,...
          doclink( '/toolbox/distcomp/distcomp_ug.map',...
          'ERR_PARFOR_NESTED_FOR_RANGE',...
          'Parallel Computing Toolbox, "parfor"')));
end
end
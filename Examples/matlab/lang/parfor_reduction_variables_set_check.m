function parfor_reduction_variables_set_check(varargin)
% Copyright 2017 The MathWorks, Inc.
% This function is undocumented and reserved for internal use. It may be
% removed in a future release.
%
% Reduction variables must exist before the parfor-loop executes.
for idx = 1:numel(varargin)
    varname = varargin{idx};
    exists = evalin('caller', ['exist(''' varname ''', ''var'' );']);
    if ~exists
        error(message('MATLAB:parfor:reduction_variable_set',...
            varname,...
            doclink('/toolbox/distcomp/distcomp_ug.map', ...
            'ERR_PARFOR_REDUCTION_VARIABLE_SET',...
            'Parallel Computing Toolbox, "parfor"')));
    end
end
end

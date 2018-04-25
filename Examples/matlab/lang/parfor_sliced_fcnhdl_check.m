function parfor_sliced_fcnhdl_check(varargin)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2009 The MathWorks, Inc.

    for idx = 1:2:numel(varargin)
        if isa(varargin{idx+1}, 'function_handle')
            error(message('MATLAB:parfor:sliced_function_handle', ...
                           varargin{idx}, varargin{idx}, ...
                           doclink('/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_FCNHDL_CHECK', ...
                                   'Parallel Computing Toolbox, "parfor"')))
        end
    end
end
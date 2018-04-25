function parfor_nested_for_endpoint_check(varname, varargin)
% This function is undocumented and reserved for internal use. It may be
% removed in a future release.
% Copyright 2007-2017 The MathWorks, Inc.
for i=1:numel(varargin)
    endpoint = varargin{i};
    if ~isscalar(endpoint) || ~isnumeric(endpoint) || ~isreal(endpoint) || ...
       ~isfinite(endpoint) || endpoint ~= round(endpoint) || (endpoint < 1)

       error(message('MATLAB:parfor:nested_for_range_endpoint_check', ...
                varname,...
                doclink( '/toolbox/distcomp/distcomp_ug.map', ...
                'ERR_PARFOR_RANGE', ...
                'Parallel Computing Toolbox, "parfor"')))
    end
end
end
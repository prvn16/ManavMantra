function endpoint = parfor_endpoint_check(varname, endpoint)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2009 The MathWorks, Inc.

% NOTE: the scalar test being done first ensures that all other tests
% return a scalar logical - the isfinite and integerness tests can produce
% vector outputs if endpoint is a vector.

%% Handle New Front-End arguemnts
% The newfe expects varname and endpoint. Legacy only expects one argument. 
if ~feature('newfe') && nargin < 2
    endpoint = varname;
end

%% Check endpoint conditions
if ~isscalar(endpoint) || ~isnumeric(endpoint) || ~isreal(endpoint) ...
   || ~isfinite(endpoint) || endpoint ~= round(endpoint)
    if feature('newfe')
        error(message('MATLAB:parfor:range_endpoint_check', ...
              varname, ...
              doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )));
    else
        error(message('MATLAB:parfor:range_endpoint', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )));
    end
end

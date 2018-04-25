function M = parfor_M_check(M)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2008 The MathWorks, Inc.

if (~isnumeric(M) || ~isreal(M) || ~isscalar(M) || M ~= round(M) || M < 0) ...
   && ~isequal(M, 'debug')
    error(message('MATLAB:parfor:maxWorkers', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )))
end

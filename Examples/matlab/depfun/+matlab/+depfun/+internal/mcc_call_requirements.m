function [parts, resources, exclusions, errors] = mcc_call_requirements(items, varargin)
% A wrapper over requirements, called from mcc
% Copyright 2016 The MathWorks, Inc.

[parts, resources, exclusions, errors] = deal({});

try
    [parts, resources, exclusions] = matlab.depfun.internal.requirements(items, varargin{:});
catch ex
    errors = getReport(ex);
end

end
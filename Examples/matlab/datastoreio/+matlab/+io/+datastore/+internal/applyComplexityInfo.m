function data = applyComplexityInfo(data, complexVariables)
% Apply complex to any part of the data that was previously complex.
%
% This is used by TallDatastore to ensure chunked complex data remains
% complex throughout the entire dataset.

%   Copyright 2017 The MathWorks, Inc.

complexVariables = complexVariables{1};
if ~(istable(data) || istimetable(data))
    if complexVariables
        data = complex(data);
    end
else
    for ii = 1 : width(data)
        data.(ii) = matlab.io.datastore.internal.applyComplexityInfo(data.(ii), complexVariables(ii));
    end
end
end

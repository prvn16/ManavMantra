function out = length(x)
%LENGTH Length of vector.
%
%   See also tall/size, tall.

% Copyright 2016 The MathWorks, Inc.

% table explicitly forbids access to LENGTH, and throws a specific error.
if any(strcmp(tall.getClass(x), {'table', 'timetable'}))
    error(message('MATLAB:table:UndefinedLengthFunction', mfilename, tall.getClass(x)));
end

szX = size(x);
out = clientfun(@iLength, szX);
% Output is guaranteed scalar-double.
out.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LENGTH picks the max out of the size vector, unless the array is empty.
function len = iLength(szVec)
if prod(szVec) == 0
    len = 0;
else
    len = max(szVec);
end
end

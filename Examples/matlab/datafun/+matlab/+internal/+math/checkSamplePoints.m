function x = checkSamplePoints(x,A,AisTimeTable,dim,errid)
%checkSamplePoints Validate SamplePoints value
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2017 The MathWorks, Inc.

if AisTimeTable
    tname = 'Row times';
else
    tname = '''SamplePoints''';
end
if (~isvector(x) && ~isempty(x)) || ...
        (~isfloat(x) && ~isduration(x) && ~isdatetime(x))
    error(message(['MATLAB:' errid ':SamplePointsInvalidDatatype']));
end
if AisTimeTable && isempty(A)
    return
end
if numel(x) ~= (size(A,dim) * ~isempty(A))
    error(message(['MATLAB:' errid ':SamplePointsLength'],size(A,dim)));
end
x = x(:);
if (isfloat(x) || isduration(x)) && any(~isfinite(x))
    error(message(['MATLAB:' errid ':SamplePointsNonFinite'],tname,'NaN'));
end
if isdatetime(x) && any(~isfinite(x))
    error(message(['MATLAB:' errid ':SamplePointsNonFinite'],tname,'NaT'));
end
if isfloat(x)
    if ~isreal(x)
        error(message(['MATLAB:' errid ':SamplePointsComplex']));
    end
    if issparse(x)
        error(message(['MATLAB:' errid ':SamplePointsSparse']));
    end
end
if any(diff(x) <= 0)
    if any(diff(x) == 0)
        error(message(['MATLAB:' errid ':SamplePointsDuplicate'],tname));
    else
        error(message(['MATLAB:' errid ':SamplePointsSorted'],tname));
    end
end

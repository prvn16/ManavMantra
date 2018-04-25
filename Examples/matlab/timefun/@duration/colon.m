function c = colon(a,d,b)
%COLON Create equally-spaced sequence of durations.
%   C = A:B creates an equally-spaced sequence of durations with a step size
%   equal to one 24-hour day. A and B are scalar durations. A:B is the same as
%   [A, A+DAYS(1), A+DAYS(2), ..., B1], where B-DAYS(1) < B1 <= B. A:B is empty
%   if A > B.
%
%   C = A:D:B creates an equally-spaced sequence of durations with steps of
%   size D. A, D, and B are scalar durations. D can also be a numeric scalar,
%   interpreted as a number of standard-length (24 hour) days. A:D:B is the same
%   as [A, A+D, A+2*D, ..., B1], where B-D < B1 <= B. A:D:B is empty if D == 0,
%   if D > 0 and A > B, or if D < 0 and A < B.
%
%   See also LINSPACE, PLUS, MINUS, DIFF, DURATION

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.replaceException

try
    if nargin < 3
        b = d;
        [millis,c] = duration.isequalUtil({a,b});
        [amillis,bmillis] = millis{:};
        dmillis = 86400*1000; % default is one day
    else
        % Numeric step input interpreted as a multiple of 24 hours.       
        [millis,c] = duration.isequalUtil({a,d,b});
        [amillis,dmillis,bmillis] = millis{:};
    end
catch ME
    if nargin > 2 && ~isa(d,'duration') && ~isa(d,'double')
        throwAsCaller(replaceException(ME,...
        {'MATLAB:datetime:DurationConversion','MATLAB:duration:InvalidComparison'},...
        message('MATLAB:duration:colon:NonNumericStep')));
    else
        throwAsCaller(replaceException(ME,...
        {'MATLAB:duration:InvalidComparison'},...
        message('MATLAB:duration:colon:DurationConversion')));
    end
end

if  ~isScalarOrTextScalar(a,amillis) || ~isScalarOrTextScalar(b,bmillis) || ~isScalarOrTextScalar(d,dmillis)
    throwAsCaller(MException(message('MATLAB:duration:colon:NonScalarInputs')));
end

c.millis = colon(amillis,dmillis,bmillis);
    
end
function tf = isScalarOrTextScalar(x,xMillis)
import matlab.internal.datatypes.isCharString
tf = (isscalar(xMillis) || isCharString(x) || (isduration(x)&&isempty(x)));
end
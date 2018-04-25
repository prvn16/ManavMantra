function tf = isbetween(a,lower,upper)
% ISBETWEEN Determine if datetimes are contained in an interval.
%   TF = ISBETWEEN(A,LOWER,UPPER) returns a logical array TF indicating which
%   datetimes in A lie within the closed interval(s) specified by LOWER and
%   UPPER. A, LOWER, and UPPER are datetime arrays with a common size, or any
%   can be a scalar.  TF is a logical array with that same common size
%   indicating which elements of A satisfy LOWER <= A <= UPPER.
%
%   A, LOWER, or UPPER can be a datetime string or a cell array of datetime
%   strings.
%
%   Examples:
%
%      % Create an array of datetimes, define upper and lower bounds, and
%      % determine which elements of the datetime array are within the
%      % bounds.
%      dt = datetime(2010,10,9:11,0,0,0)
%      dt_lower = datetime(2010, 10, 6:3:12,0,0,0)
%      dt_upper = datetime(2010,10,8:2:12,0,0,0)
%
%      isbetween(dt,dt_lower,dt_upper)
%
%      % if the datetime to test is scalar
%      dt2 = datetime(2010,10,9,0,0,0);
%
%      isbetween(dt2,dt_lower,dt_upper)
%
%      % if one of the limits is scalar
%      dt_lower2 = datetime(2010,10,6,0,0,0);
%
%      isbetween(dt,dt_lower2,dt_upper)
%
%      % A more complex example:
%      % Define a lower bound and an upper bound for dates. 
%      tlower = datetime(2014,05,16)
%      tupper = '23-May-2014'
%      % tlower and tupper can be datetime arrays or strings. Here, tlower
%      % is a datetime array and tupper is a single string.
%
%      % Create an array of datetime values and determine if each datetime lies
%      % within the interval bounded by tlower and tupper.
%      t = tlower + caldays(2:2:10)
%
%      tf = isbetween(t,tlower,tupper)
%
%   See also ISMEMBER, LT, LE, GE, GT.

%   Copyright 2014-2016 The MathWorks, Inc.

[aData,lData,uData] = isbetweenUtil(a,lower,upper);
tf = (relopSign(lData,aData) <= 0) & (relopSign(aData,uData) <= 0);


%-----------------------------------------------------------------------
function [aData,lData,uData] = isbetweenUtil(a,lower,upper)
% A single (valid) date string is accepted as a scalar datetime for any of the
% inputs.  If the conversion fails, drop through to the catch-all error below.

import matlab.internal.datatypes.isCharStrings

try
    if (isstring(a) && isscalar(a)) || isCharStrings(a)
        % Either lower or upper must be a datetime
        if isa(lower,'datetime'), template = lower; else template = upper; end
        a = autoConvertStrings(a,template);
    end
    if (isstring(lower) && isscalar(lower)) || isCharStrings(lower)
        % Either a or upper must be a datetime
        if isa(upper,'datetime'), template = upper; else template = a; end
        lower = autoConvertStrings(lower,template);
    end
    if (isstring(upper) && isscalar(upper)) || isCharStrings(upper)
        % Either a or lower must be a datetime
        if isa(lower,'datetime'), template = lower; else template = a; end
        upper = autoConvertStrings(upper,template);
    end
catch ME
    throwAsCaller(ME);
end

if ~isa(a,'datetime') || ~isa(lower,'datetime') || ~isa(upper,'datetime')
    error(message('MATLAB:datetime:isbetween:InvalidInput'));
end

if isscalar(a)
    sizeMismatch = ~isscalar(lower) && ~isscalar(upper) && ~isequal(size(lower),size(upper));
else
    if isscalar(lower)
        sizeMismatch = ~isscalar(upper) && ~isequal(size(a),size(upper));
    else
        sizeMismatch = (~isequal(size(a),size(lower))) ...
            || (~isscalar(upper) && ~isequal(size(a),size(upper)));
    end
end
if sizeMismatch
    error(message('MATLAB:datetime:isbetween:InputSizeMismatch'));
end

if isempty(a.tz) ~= isempty(lower.tz) || isempty(a.tz) ~= isempty(upper.tz)
    error(message('MATLAB:datetime:IncompatibleTZ'));
end
aData = a.data;
lData = lower.data;
uData = upper.data;

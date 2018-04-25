function b = std(a,flag,dim,missing)
%STD Standard deviation of datetimes.
%   SD = STD(T), when T is a vector of datetimes, returns the sample standard
%   deviation of T as a scalar duration SD. When T is a matrix, STD(T) is a row
%   vector containing the standard deviation of each column.  For N-D arrays,
%   STD(T) is the standard deviation of the elements along the first
%   non-singleton dimension of T.
%
%   STD normalizes by (N-1), where N is the sample size.
%
%   SD = STD(T,1) normalizes by N. STD(T,0) is the same as STD(T).
%
%   SD = STD(T,FLAG,DIM) takes the standard deviation along the dimension DIM of
%   T.  Pass in FLAG==0 to use the default normalization by N-1, or 1 to use N.
%
%   SD = STD(..., MISSING) specifies how NaT (Not-A-Time) values are treated.
%
%      'includenat' - the standard deviation of a vector containing any NaT
%                     values is also NaT. This is the default. 'includenan' is
%                     equivalent to 'includenat'.
%      'omitnat'    - elements of T containing NaT values are ignored. If all
%                     elements are NaT, the result is NaT. 'omitnan' is
%                     equivalent to 'omitnat'.
%
%   Example:
%      % Create an array of random datetimes distributed around a specified
%      % datetime and calculate the standard deviation.  Randn uses a
%      % default distribution with width s.d.=1.0, so the result should be
%      % approximately 1 day.
%      dts = datetime('21-Oct-2015 12:01:00') + days(randn(1000,1));
%      std(dts)
%
%   See also MEAN, MEDIAN, MODE.

%   Copyright 2015-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

needDim = true;
omitNan = false;

if nargin == 1
    flag = 0;
else
    % Recognize FLAG, and then DIM, if present as the 2nd and 3rd inputs, and
    % recognize a trailing string option if present. The core std function will do
    % more complete validation on FLAG and DIM.
    if isnumeric(flag)
        if nargin == 2 % std(a,flag)
            % OK
        else
            if isnumeric(dim)
                needDim = false;
                if nargin == 3 % std(a,flag,dim)
                    % OK
                else % std(a,flag,dim,missing)
                    omitNan = validateMissingOption(missing);
                end
            elseif isCharString(dim) && (nargin == 3) % std(a,flag,missing)
                omitNan = validateMissingOption(dim); % missing is in dim's position
            else
                error(message('MATLAB:datetime:InvalidDim'));
            end
        end
    elseif isCharString(flag) && (nargin == 2) % std(a,missing)
        omitNan = validateMissingOption(flag); % missing is in flag's position
        flag = 0;
    else
        % Let the core std throw the error for FLAG
    end
end

aData = a.data;
if needDim
    dim = find(size(aData)~=1,1);
    if isempty(dim), dim = 1; end
end

% Compute (duration) differences from the (datetime) mean. This preserves
% maximal precision in the conversion to double.
if omitNan
    if needDim
        m = mean(a,'omitnan');
    else
        m = mean(a,dim,'omitnan');
    end
else
    if needDim
        m = mean(a);
    else
        m = mean(a,dim);
    end
end
if isscalar(m)
    mData = m.data;
else
    repSz = ones(1,ndims(aData)); repSz(dim) = size(aData,dim);
    mData = repmat(m.data,repSz);
end
dm = matlab.internal.datetime.datetimeSubtract(aData,mData); % returns double

% Call the core std function to leverage its input checking on FLAG.
if omitNan
    if needDim
        b = duration.fromMillis(std(dm,flag,'omitnan'));
    else
        b = duration.fromMillis(std(dm,flag,dim,'omitnan'));
    end
else
    if needDim
        b = duration.fromMillis(std(dm,flag));
    else
        b = duration.fromMillis(std(dm,flag,dim));
    end
end

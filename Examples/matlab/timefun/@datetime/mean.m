function b = mean(a,dim,option1,option2)
%MEAN Mean of datetimes.
%   M = MEAN(T), when T is a vector of datetimes, returns the sample mean of T
%   as a scalar datetime M. When T is a matrix, MEAN(T) is a row vector
%   containing the mean value of each column.  For N-D arrays, MEAN(T) is the
%   mean value of the elements along the first non-singleton dimension of T.
%   
%   M = MEAN(T,DIM) takes the mean along the dimension DIM of T.
%
%   M = MEAN(..., MISSING) specifies how NaT (Not-A-Time) values are treated.
%
%      'includenat' - the mean of a vector containing any NaT values is also NaT.
%                     This is the default. 'includenan' is equivalent to
%                     'includenat'.
%      'omitnat'    - elements of T containing NaT values are ignored. If all
%                     elements are NaT, the result is NaT. 'omitnan' isequivlant
%                     to 'omitnat'.
%
%   % Example:
%      % Create an array of random datetimes distributed around a specified
%      % datetime and calculate the mean.  Should return a value near the
%      % original specified datetime.
%      dts = datetime('21-Oct-2015 12:01:00') + days(randn(100,1))
%      mean(dts)
%
%   See also STD, MEDIAN, MODE.

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

needDim = true;
omitnan = false;

if nargin > 1
    % Recognize DIM if present as the 2nd input, and recognize any trailing string
    % options if present.
    if isnumeric(dim) % mean(a,dim,...)
        needDim = false;
        nopts = nargin - 2;
    elseif isCharString(dim) && (nargin < 4) % no DIM, but there are options
        nopts = nargin - 1;
        if nopts == 1 % mean(a,option1)
            % OK
        else % mean(a,option1,option2)
            option2 = option1; % 2nd option string is in 1st option's position
        end
        option1 = dim; % 1st option string is in dim's position
    else
        error(message('MATLAB:datetime:InvalidDim'));
    end
    
    % Validate the options strings.
    if nopts > 0
        [omitnan,haveOption] = validateMissingOptionLocal(option1,omitnan);
        if nopts > 1
            omitnan = validateMissingOptionLocal(option2,omitnan,haveOption);
        end
    end
end

aData = a.data;
b = a;
if needDim
    b.data = matlab.internal.datetime.datetimeMean(aData,omitnan);
else
    b.data = matlab.internal.datetime.datetimeMean(aData,dim,omitnan);
end

%-----------------------------------------------------------------------
function [omitnan,haveOption] = validateMissingOptionLocal(option,omitnan,haveOption)
% Accept 'includenat' and 'omitnat' (and their nan versions), and accept
% 'default' and 'native' (ultimately these are no-ops), but error for 'double'.
% Only accept one from each set.
if nargin < 3
    % haveOption tracks how many of each missing and type options have been found
    % already, to catch things like mean(x,'onitnan','includenan').
    haveOption = zeros(1,2); % missing flags and type flags, respectively
end

try
    % Try to interpret the option as a missing flag. If that fails, the catch
    % will try to interpet it as a type flag, and omitnan will be unchanged.
    omitnan = validateMissingOption(option);
    haveOption(1) = haveOption(1) + 1; % this was a missing flag
catch ME
    s = strncmpi(option, {'double' 'default' 'native'}, max(length(option),1));
    if s(1) % 'double', an error
        if s(2) % ambiguous match 'd'
            throwAsCaller(MException(message('MATLAB:datetime:UnknownOption')));
        else
            throwAsCaller(MException(message('MATLAB:datetime:InvalidNumericConversion',option)));
        end
    elseif s(2) || s(3) % 'default' or 'native'
        haveOption(2) = haveOption(2) + 1; % this was a type flag
    elseif strcmp(ME.identifier,'MATLAB:datetime:UnknownNaNFlag')
        % validateMissingOption didn't recognize it, nor did the above strncmpi.
        throwAsCaller(MException(message('MATLAB:datetime:UnknownOption')));
    else
        rethrow(ME)
    end
end

% Make sure this is the first time that option has been seen.
if any(haveOption > 1)
    throwAsCaller(MException(message('MATLAB:datetime:UnknownOption')));
end

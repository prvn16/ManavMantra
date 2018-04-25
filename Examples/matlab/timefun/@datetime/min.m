function [c,i] = min(a,b,dim,natFlag)
%MIN Find minimum of datetimes.
%   M = MIN(A), when A is a vector of datetimes, returns the smallest element of
%   A as a scalar datetime M. When A is a matrix, MIN(A) is a row vector
%   containing the smallest value of each column.  For N-D arrays, MIN(A) is the
%   smallest value of the elements along the first non-singleton dimension of A.
%   
%   [M,I] = MIN(A) returns the indices of the minimum values in vector I. If the
%   values along the first non-singleton dimension contain more than one minimal
%   element, the index of the first one is returned.
%   
%   M = MIN(A,B) returns a datetime array the same size as A and B with the
%   smallest elements taken from A or B. Either one can be a scalar.
%   
%   [M,I] = MIN(A,[],DIM) operates along the dimension DIM.
%   
%   MIN(..., NATFLAG) specifies how NaT (Not-A-Time) values are treated.
%      'omitnat'    - Ignores all NaT values and returns the minimum of the
%                     non-NaT elements. If all elements are NaT, then the first
%                     one is returned. 'omitnan' is equivalent to 'omitnat'.
%      'includenat' - Returns NaT if there is any NaT value. The index points
%                     to the first NaT element. 'includenan' is equivalent to
%                     'includenat'.
%   Default is 'omitnat'.
%   
%   Example:
%      
%      % Find the minimum of a vector of datetimes.
%      t = datetime(2017,1,randi(31,3,1))
%      tmin = min(t)
%
%      % Find the elementwise minimum between two datetime vectors, first by
%      % omitting NaT elements, then including them.
%      t1 = datetime(2017,1,[1   2 3 NaN])
%      t2 = datetime(2017,1,[4 NaN 2   1])
%      tminOmit = min(t1,t2)
%      tminInclude = min(t1,t2,'includenat')
%
%      % Find the elementwise minimum between two datetime vectors that have
%      % different display formats.  The result has the same format as the first
%      % input.
%      t1 = datetime(2017,1,[1 2 3 4],'Format','dd-MMM-yyyy')
%      t2 = datetime(2017,1,[4 3 2 1],'Format','yyyy-MM-dd')
%      tmin = min(t1,t2)
%
%      % Find minimum between two datetime vectors that have different time
%      % zones. MIN accounts for the time difference between time zones, and
%      % the result has the same time zone as the first input.
%      t1 = datetime('1-Jan-2017 12:00:00', 'TimeZone', 'America/Los_Angeles')
%      t2 = datetime('1-Jan-2017 12:00:00', 'TimeZone', 'America/Chicago')
%      tmin = min(t1,t2)
%      tmin.TimeZone
%
%   See also MAX, MEDIAN, MEAN, SORT.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.minMaxBinary
import matlab.internal.datetime.minMaxUnary
import matlab.internal.datatypes.isScalarInt

haveDim = false;
omitNan = true;
if nargin < 4, natFlag = 'omitnan'; end

if nargin == 1 % min(a)
    isUnary = true;
elseif nargin == 2 % min(a,b), including min(a,[])
    isUnary = false;
    if nargout > 1
        error(message('MATLAB:datetime:TwoInTwoOutCaseNotSupported', 'MIN'));
    end
else
    isUnary = isnumeric(b) && isequal(b,[]);
    if isnumeric(dim) || nargin == 4 % min(a,[],dim) or min(a,[],dim,nanFlag)
        if ~isScalarInt(dim,1)
            error(message('MATLAB:datetime:InvalidDim'));
        end
        if nargin == 4
            [omitNan,natFlag] = validateMissingOption(natFlag);
        end
        haveDim = true;
    else % min(a,[],nanFlag) or min(a,b,nanFlag)
        [omitNan,natFlag] = validateMissingOption(dim);
    end
end

if isUnary % min(a,b,dim) not legal
    if ~haveDim
        dim = find(size(a.data)~=1,1);
        if isempty(dim), dim = 1; end
    end
else
    if haveDim
        error(message('MATLAB:datetime:TwoInWithDimCaseNotSupported', 'MIN'));
    end
    dim = [];
end

if isUnary
    c = a;
    aData = a.data;
    if isreal(aData)
        if nargout <= 1
            c.data = min(aData,[],dim,natFlag);
        else
            [c.data,i] = min(aData,[],dim,natFlag);
        end
    else
        if nargout <= 1
            c.data = minMaxUnary(aData,dim,omitNan,false);
        else
            [c.data,i] = minMaxUnary(aData,dim,omitNan,false);
        end
    end
else
    [aData,bData,c] = datetime.compareUtil(a,b);
    if isreal(aData) && isreal(bData)
        c.data = min(aData,bData,natFlag);
    else
        c.data = minMaxBinary(aData,bData,omitNan,false);
    end
end

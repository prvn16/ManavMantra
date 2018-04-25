function [c,i] = max(a,b,dim,natFlag)
%MAX Find maximum of datetimes.
%   M = MAX(A), when A is a vector of datetimes, returns the largest element of
%   A as a scalar datetime M. When A is a matrix, MAX(A) is a row vector
%   containing the largest value of each column.  For N-D arrays, MAX(A) is the
%   largest value of the elements along the first non-singleton dimension of A.
%   
%   [M,I] = MAX(A) returns the indices of the maximum values in vector I. If the
%   values along the first non-singleton dimension contain more than one maximal
%   element, the index of the first one is returned.
%   
%   M = MAX(A,B) returns a datetime array the same size as A and B with the
%   largest elements taken from A or B. Either one can be a scalar.
%   
%   [M,I] = MAX(A,[],DIM) operates along the dimension DIM.
%
%   MAX(..., NATFLAG) specifies how NaT (Not-A-Time) values are treated.
%      'omitnat'    - Ignores all NaT values and returns the maximum of the
%                     non-NaT elements. If all elements are NaT, then the first
%                     one is returned. 'omitnan' is equivalent to 'omitnat'.
%      'includenat' - Returns NaT if there is any NaT value. The index points
%                     to the first NaT element. 'includenan' is equivalent to
%                     'includenat'.
%   Default is 'omitnat'.
%
%   Examples:
%      
%      % Find the maximum of a vector of datetimes.
%      t = datetime(2017,1,randi(31,3,1))
%      tmax = max(t)
%
%      % Find the elementwise maximum between two datetime vectors, first by
%      % omitting NaT elements, then including them.
%      t1 = datetime(2017,1,[1   2 3 NaN])
%      t2 = datetime(2017,1,[4 NaN 2   1])
%      tmaxOmit = max(t1,t2)
%      tmaxInclude = max(t1,t2,'includenat')
%
%      % Find the elementwise maximum between two datetime vectors that have
%      % different display formats. The result has the same format as the first
%      % input.
%      t1 = datetime(2017,1,[1 2 3 4],'Format','dd-MMM-yyyy')
%      t2 = datetime(2017,1,[4 3 2 1],'Format','yyyy-MM-dd')
%      tmax = max(t1,t2)
%
%      % Find maximum between two datetime vectors that have different time
%      % zones. MAX accounts for the time difference between time zones, and
%      % the result has the same time zone as the first input.
%      t1 = datetime('1-Jan-2017 12:00:00', 'TimeZone', 'America/New_York')
%      t2 = datetime('1-Jan-2017 12:00:00', 'TimeZone', 'America/Chicago')
%      tmax = max(t1,t2)
%      tmax.TimeZone
%
%   See also MIN, MEDIAN, MEAN, SORT.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.minMaxBinary
import matlab.internal.datetime.minMaxUnary
import matlab.internal.datatypes.isScalarInt

haveDim = false;
omitNan = true;
if nargin < 4, natFlag = 'omitnan'; end

if nargin == 1 % max(a)
    isUnary = true;
elseif nargin == 2 % max(a,b), including max(a,[])
    isUnary = false;
    if nargout > 1
        error(message('MATLAB:datetime:TwoInTwoOutCaseNotSupported', 'MAX'));
    end
else
    isUnary = isnumeric(b) && isequal(b,[]);
    if isnumeric(dim) || nargin == 4 % max(a,[],dim) or max(a,[],dim,nanFlag)
        if ~isScalarInt(dim,1)
            error(message('MATLAB:datetime:InvalidDim'));
        end
        if nargin == 4
            [omitNan,natFlag] = validateMissingOption(natFlag);
        end
        haveDim = true;
    else % max(a,[],nanFlag) or max(a,b,nanFlag)
        [omitNan,natFlag] = validateMissingOption(dim);
    end
end

if isUnary % max(a,b,dim) not legal
    if ~haveDim
        dim = find(size(a.data)~=1,1);
        if isempty(dim), dim = 1; end
    end
else
    if haveDim
        error(message('MATLAB:datetime:TwoInWithDimCaseNotSupported', 'MAX'));
    end
    dim = [];
end

if isUnary
    c = a;
    aData = a.data;
    if isreal(aData)
        if nargout <= 1
            c.data = max(aData,[],dim,natFlag);
        else
            [c.data,i] = max(aData,[],dim,natFlag);
        end
    else
        if nargout <= 1
            c.data = minMaxUnary(aData,dim,omitNan,true);
        else
            [c.data,i] = minMaxUnary(aData,dim,omitNan,true);
        end
    end
else
    [aData,bData,c] = datetime.compareUtil(a,b);
    if isreal(aData) && isreal(bData)
        c.data = max(aData,bData,natFlag);
    else
        c.data = minMaxBinary(aData,bData,omitNan,true);
    end
end

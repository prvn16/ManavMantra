function [c,i] = max(a,b,varargin)
%MAX Find maximum of durations.
%   M = MAX(A), when A is a vector of durations, returns the largest element of
%   A as a scalar duration M. When A is a matrix, MAX(A) is a row vector
%   containing the largest value of each column.  For N-D arrays, MAX(A) is the
%   largest value of the elements along the first non-singleton dimension of A.
%   
%   [M,I] = MAX(A) returns the indices of the maximum values in vector I. If the
%   values along the first non-singleton dimension contain more than one maximal
%   element, the index of the first one is returned.
%   
%   M = MAX(A,B) returns a duration array the same size as A and B with the
%   largest elements taken from A or B. Either one can be a scalar.
%   
%   [M,I] = MAX(A,[],DIM) operates along the dimension DIM.
%   
%   MAX(..., NANFLAG) specifies how NaN (Not-A-Number) values are treated.
%      'omitnan'    - Ignores all NaN values and returns the maximum of the
%                     non-NaN elements. If all elements are NaN, then the first
%                     one is returned.
%      'includenan' - Returns NaN if there is any NaN value. The index points
%                     to the first NaN element.
%   Default is 'omitnan'.
%   
%   Examples:
%      
%      % Find the maximum of a vector of durations.
%      t = hours(randn(3,1))
%      tmax = max(t)
%
%      % Find the elementwise maximum between two duration vectors, first by
%      % omitting NaN elements, then including them.
%      t1 = hours([1   2 3 NaN])
%      t2 = hours([4 NaN 2   1])
%      tmaxOmit = max(t1,t2)
%      tmaxInclude = max(t1,t2,'includenan')
%
%      % Find the elementwise maximum between two duration vectors that have
%      % different display formats. The result has the same format as the first
%      % input.
%      t1 = hours([1 2 3 4])
%      t2 = minutes(60*[4 3 2 1])
%      tmax = max(t1,t2)
%
%   See also MIN, MEDIAN, MEAN, SORT.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 2 ... % max(a)
        || (nargin > 2 && isnumeric(b) && isequal(b,[])) % max(a,[],...) but not max(a,[])
    c = a;
    if nargin < 2
        if nargout <= 1
            c.millis = max(a.millis);
        else
            [c.millis,i] = max(a.millis);
        end
    else
        if nargout <= 1
            c.millis = max(a.millis,[],varargin{:});
        else
            [c.millis,i] = max(a.millis,[],varargin{:});
        end
    end
else % max(a,b) or max(a,b,...)
    [amillis,bmillis,c] = duration.compareUtil(a,b);
    if nargout <= 1
        c.millis = max(amillis,bmillis,varargin{:});
    else
        [c.millis,i] = max(amillis,bmillis,varargin{:});
    end
end

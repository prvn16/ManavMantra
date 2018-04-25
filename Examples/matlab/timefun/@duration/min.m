function [c,i] = min(a,b,varargin)
%MIN Find minimum of durations.
%   M = MIN(A), when A is a vector of durations, returns the smallest element of
%   A as a scalar duration M. When A is a matrix, MIN(A) is a row vector
%   containing the smallest value of each column.  For N-D arrays, MIN(A) is the
%   smallest value of the elements along the first non-singleton dimension of A.
%   
%   [M,I] = MIN(A) returns the indices of the minimum values in vector I. If the
%   values along the first non-singleton dimension contain more than one minimal
%   element, the index of the first one is returned.
%   
%   M = MIN(A,B) returns a duration array the same size as A and B with the
%   smallest elements taken from A or B. Either one can be a scalar.
%   
%   [M,I] = MIN(A,[],DIM) operates along the dimension DIM.
%   
%   MIN(..., NANFLAG) specifies how NaN (Not-A-Number) values are treated.
%      'omitnan'    - Ignores all NaN values and returns the minimum of the
%                     non-NaN elements. If all elements are NaN, then the first
%                     one is returned.
%      'includenan' - Returns NaN if there is any NaN value. The index points
%                     to the first NaN element.
%   Default is 'omitnan'.
%   
%   Examples:
%      
%      % Find the minimum of a vector of durations.
%      t = hours(randn(3,1))
%      tmin = min(t)
%
%      % Find the elementwise minimum between two duration vectors, first by
%      % omitting NaN elements, then including them.
%      t1 = hours([1   2 3 NaN])
%      t2 = hours([4 NaN 2   1])
%      tminOmit = min(t1,t2)
%
%      % Find the elementwise minimum between two duration vectors that have
%      % different display formats. The result has the same format as the first
%      % input.
%      t1 = hours([1 2 3 4])
%      t2 = minutes(60*[4 3 2 1])
%      tmin = min(t1,t2)
%      tminInclude = min(t1,t2,'includenan')
%   
%   See also MAX, MEDIAN, MEAN, SORT.

%   Copyright 2014-2017 The MathWorks, Inc.

if nargin < 2 ... % min(a)
        || (nargin > 2 && isnumeric(b) && isequal(b,[])) % min(a,[],...) but not min(a,[])
    c = a;
    if nargin < 2
        if nargout <= 1
            c.millis = min(a.millis);
        else
            [c.millis,i] = min(a.millis);
        end
    else
        if nargout <= 1
            c.millis = min(a.millis,[],varargin{:});
        else
            [c.millis,i] = min(a.millis,[],varargin{:});
        end
    end
else % min(a,b) or min(a,b,...)
    [amillis,bmillis,c] = duration.compareUtil(a,b);
    if nargout <= 1
        c.millis = min(amillis,bmillis,varargin{:});
    else
        [c.millis,i] = min(amillis,bmillis,varargin{:});
    end
end
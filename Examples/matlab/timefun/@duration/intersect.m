function [c,ia,ib] = intersect(a,b,varargin)
%INTERSECT Find durations common to two arrays.
%   C = INTERSECT(A,B) for duration arrays A and B, returns the values common to
%   the two arrays with no repetitions.  C is vector sorted in ascending order.
%
%   C = INTERSECT(A,B,'rows') for duration matrices A and B with the same number
%   of columns, returns the rows common to the two matrices. The rows of the
%   matrix C are sorted in ascending order.
%
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB such that C
%   = A(IA) and C = B(IB). If A and B are row vectors, then C will be a row
%   vector as well, otherwise C will be a column vector. IA and IB are column
%   vectors. If there are repeated common values in A or B then the index of the
%   first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows') also returns index vectors IA and IB such
%   that C = A(IA,:) and C = B(IB,:).
%
%   [C,IA,IB] = INTERSECT(A,B,'stable') for duration arrays A and B, returns the
%   values of C in the same order that they appear in A, while INTERSECT(A,B,'sorted')
%   returns the values of C in sorted order.
%
%   [C,IA,IB] = INTERSECT(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while INTERSECT(A,B,'rows','sorted') returns
%   the rows of C in sorted order.
%
%   Example:
%      % create two overlapping arrays of durations in different formats
%      % and find their intersection.
%      dur1 = minutes(0:3)
%      dur2 = seconds(30:30:120)
%      intersect(dur1,dur2)

%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

[amillis,bmillis,c] = duration.compareUtil(a,b);

if nargout < 2
    c.millis = intersect(amillis,bmillis,varargin{:});
else
    [c.millis,ia,ib] = intersect(amillis,bmillis,varargin{:});
end

function [c,ia,ib] = setxor(a,b,varargin)
%SETXOR Find durations that occur in one or the other of two arrays, but not both.
%   C = SETXOR(A,B) for duration arrays A and B, returns the values that are not
%   in the intersection of A and B with no repetitions. C is a vector sorted in
%   ascending order.
%
%   C = SETXOR(A,B,'rows') for duration matrices A and B with the same number of
%   columns, returns the rows that are not in the intersection of A and B. The
%   rows of the matrix C are sorted in ascending order.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that C is
%   a sorted combination of the values A(IA) and B(IB). If A and B are row
%   vectors, then C will be a row vector as well, otherwise C will be a column
%   vector. IA and IB are column vectors. If there are repeated values that are
%   not in the intersection of A and B, then the index of the first occurrence
%   of each repeated value is returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows') also returns index vectors IA and IB such
%   that C is the sorted combination of rows A(IA,:) and B(IB,:).
%
%   [C,IA,IB] = SETXOR(A,B,'stable') for duration arrays A and B, returns the
%   values of C in the same order that they appear in A and in B, while
%   SETXOR(A,B,'sorted') returns the values of C in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A and in B, while SETXOR(A,B,'rows','sorted')
%   returns the rows of C in sorted order.
%
%   Example:
%      % create two overlapping arrays of durations in different formats
%      % and find the values in one or the other but not both.
%      dur1 = minutes(0:3)
%      dur2 = seconds(30:30:120)
%      setxor(dur1,dur2)
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

[amillis,bmillis,c] = duration.compareUtil(a,b);

if nargout < 2
    c.millis = setxor(amillis,bmillis,varargin{:});
else
    [c.millis,ia,ib] = setxor(amillis,bmillis,varargin{:});
end

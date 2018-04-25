function [c,ia] = setdiff(a,b,varargin)
%SETDIFF Find durations that occur in one array but not in another.
%   C = SETDIFF(A,B) for duration arrays A and B, returns the values in A that
%   are not in B with no repetitions. C is a vector sorted in ascending order.
%
%   C = SETDIFF(A,B,'rows') for duration matrices A and B with the same number
%   of columns, returns the rows from A that are not in B. The rows of the
%   matrix C are in sorted order.
%
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that C = A(IA).
%   If A is a row vector, then C will be a row vector as well, otherwise C will
%   be a column vector. IA is a column vector. If there are repeated values in A
%   that are not in B, then the index of the first occurrence of each repeated
%   value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows') also returns an index vector IA such that C =
%   A(IA,:).
%
%   [C,IA] = SETDIFF(A,B,'stable') for duration arrays A and B, returns the
%   values of C in the order that they appear in A, while SETDIFF(A,B,'sorted')
%   returns the values of C in sorted order.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while SETDIFF(A,B,'rows','sorted') returns the
%   rows of C in sorted order.
%
%   Example:
%      % create two overlapping arrays of durations in different formats
%      % and find the values in dur1 that are not in dur2 and vice versa.
%      dur1 = minutes(0:3)
%      dur2 = seconds(30:30:120)
%      setdiff(dur1,dur2)
%      setdiff(dur2,dur1)
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

[amillis,bmillis,c] = duration.compareUtil(a,b);

if nargout < 2
    c.millis = setdiff(amillis,bmillis,varargin{:});
else
    [c.millis,ia] = setdiff(amillis,bmillis,varargin{:});
end


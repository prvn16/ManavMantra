function [c,ia,ib] = union(a,b,varargin)
%UNION Find durations that occur in either of two arrays.
%   C = UNION(A,B) for duration arrays A and B, returns the combined values of
%   the two arrays with no repetitions.  C is a vector sorted in ascending
%   order.
%  
%   C = UNION(A,B,'rows') for duration matrices A and B with the same number of
%   columns, returns the combined rows from the two matrices with no
%   repetitions.  The rows of the matrix C are sorted in ascending order.
% 
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such that C is a
%   sorted combination of the values A(IA) and B(IB). If A and B are row
%   vectors, then C will be a row vector as well, otherwise C will be a column
%   vector. IA and IB are column vectors. If there are common values in A and B,
%   then the index is returned in IA. If there are repeated values in A or B,
%   then the index of the first occurrence of each repeated value is returned.
%
%   [C,IA,IB] = UNION(A,B,'rows') also returns index vectors IA and IB such that
%   C is the sorted combination of the rows A(IA,:) and B(IB,:).
% 
%   [C,IA,IB] = UNION(A,B,'stable') for duration arrays A and B, returns the
%   values of C in the same order that they appear in A and in B, while
%   UNION(A,B,'sorted') returns the values of C in sorted order.
%
%   [C,IA,IB] = UNION(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A and in B, while UNION(A,B,'rows','sorted')
%   returns the rows of C in sorted order.
%
%   Example:
%      % create two overlapping arrays of durations in different formats
%      % and find their union.
%      dur1 = minutes(0:3)
%      dur2 = seconds(30:30:120)
%      union(dur1,dur2)
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

[amillis,bmillis,c] = duration.compareUtil(a,b);

if nargout < 2
    c.millis = union(amillis,bmillis,varargin{:});
else
    [c.millis,ia,ib] = union(amillis,bmillis,varargin{:});
end


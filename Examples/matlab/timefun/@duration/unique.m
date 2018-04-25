function [b,i,j] = unique(a,varargin)
%UNIQUE Find unique durations in an array.
%   B = UNIQUE(A) returns the same durations as in A but with no repetitions. B
%   is a vector sorted in ascending order.
%  
%   B = UNIQUE(A,'rows') for the duration matrix A returns the unique rows of A.
%   The rows of the matrix C are sorted in ascending order.
%
%   [C,IA,IC] = UNIQUE(A) also returns index vectors IA and IC such that C =
%   A(IA) and A = C(IC). If A is a row vector, then C will be a row vector as
%   well, otherwise C will be a column vector. IA and IC are column vectors. If
%   there are repeated values in A, then IA returns the index of the first
%   occurrence of each repeated value.
%  
%   [C,IA,IC] = UNIQUE(A,'rows') also returns index vectors IA and IC such that
%   C = A(IA,:) and A = C(IC,:).
%
%   [C,IA,IC] = UNIQUE(A,OCCURRENCE) UNIQUE(A,'rows',OCCURRENCE) specify which
%   index is returned in IA in the case of repeated values (or rows) in A. The
%   default value for OCCURRENCE is 'first', which returns the index of the
%   first occurrence of each repeated value (or row) in A, while 'last' returns
%   the index of the last occurrence of each repeated value (or row) in A.
%  
%   [C,IA,IC] = UNIQUE(A,'stable') returns the values of C in the same order
%   that they appear in A, while UNIQUE(A,'sorted') returns the values of C in
%   sorted order.
%
%   [C,IA,IC] = UNIQUE(A,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while UNIQUE(A,'rows','sorted') returns the
%   rows of C in sorted order.
%
%   Example:
%      % Find the unique values in a vector of durations that is not
%      % sorted and that contains repeated values.
%      dur = hours([4 3 2 1 1 2 3 4])
%      unique(dur)
%
%   See also UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2014-2017 The MathWorks, Inc.

b = a;
[b.millis,i,j] = unique(a.millis,varargin{:});


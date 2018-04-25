function [b,i,j] = unique(a,varargin)
%UNIQUE Find unique datetimes in an array.
%   B = UNIQUE(A) returns the same datetimes as in A but with no repetitions. B
%   is a vector sorted in ascending order.
%  
%   B = UNIQUE(A,'rows') for the datetime matrix A returns the unique rows of A.
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
%   [C,IA,IC] = UNIQUE(A,OCCURRENCE) and UNIQUE(A,'rows',OCCURRENCE) specify
%   which index is returned in IA in the case of repeated values (or rows) in A.
%   The default value for OCCURRENCE is 'first', which returns the index of the
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
%
%      % Create array of datetimes with duplicate values.
%      dts = [datetime(2010,1,3:-1:1,0,0,0) datetime(2010,1,3:3:6,0,0,0)]
%
%      % Find unique datetimes in the array.
%      unique(dts)
%
%      % Find unique values and index vectors IA,IC
%      [C,IA,IC] = unique(dts)
%
%   See also UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

sorted = true; % default is true if unprovided
for i = 1:length(varargin)
	if strcmp(varargin{i},'stable')
        sorted = false;
    end
end

rows = false;
for i = 1:length(varargin)
	if strcmp(varargin{i},'rows')
        rows = true;
    end
end

b = a;
aData = a.data + 0; % ensure an all-zero imag part is dropped

[bData,i,j] = unique(aData,varargin{:});

if sorted
    [bData,i,reord] = setMembershipSort(bData,i,rows);
    ireord(reord) = 1:length(reord);
    j(:) = ireord(j);
end
b.data = bData;

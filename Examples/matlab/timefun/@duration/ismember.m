function [lia,locb] = ismember(a,b,varargin)
%ISMEMBER Find durations in one array that occur in another array.
%   LIA = ISMEMBER(A,B) for duration arrays A and B, returns a logical array
%   with the same size as A containing true where the elements of A are in B and
%   false otherwise.
%
%   LIA = ISMEMBER(A,B,'rows') for duration matrices A and B with the same
%   number of columns, returns a logical vector containing true where the rows
%   of A are also rows of B and false otherwise.
%
%   [LIA,LOCB] = ISMEMBER(A,B) also returns an index array LOCB containing the
%   lowest absolute index in B for each element in A which is a member of B and
%   0 if there is no such index.
%
%   [LIA,LOCB] = ISMEMBER(A,B,'rows') also returns an index vector LOCB
%   containing the lowest absolute index in B for each row in A which is a
%   member of B and 0 if there is no such index.
%
%   Example:
%      % create two overlapping arrays of durations in different formats
%      dur1 = minutes(0:3)
%      dur2 = seconds(30:30:120)
%
%      % find which members of dur1 are in dur2
%      ismember(dur1,dur2)
%      % find which members of dur2 are in dur1
%      ismember(dur2,dur1)
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR.

%   Copyright 2014 The MathWorks, Inc.

[amillis,bmillis] = duration.compareUtil(a,b);

if nargout < 2
    lia = ismember(amillis,bmillis,varargin{:});
else
    [lia,locb] = ismember(amillis,bmillis,varargin{:});
end

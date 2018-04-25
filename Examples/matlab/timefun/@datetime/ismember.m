function [lia,locb] = ismember(a,b,varargin)
%ISMEMBER Find datetimes in one array that occur in another array.
%   LIA = ISMEMBER(A,B) for datetime arrays A and B, returns a logical array
%   with the same size as A containing true where the elements of A are in B and
%   false otherwise.
%
%   A or B can also be a datetime string or a cell array of datetime strings.
%
%   LIA = ISMEMBER(A,B,'rows') for datetime matrices A and B with the same
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
%
%      % Create two arrays of datetimes.
%      dt1 = datetime(2015,10,1,0:4,0,0)
%      dt2 = datetime(2015,10,1,2:2:6,0,0)
%
%      % Find which elements of dt1 are in dt2 and indices.
%      [LIA, LOBC] = ismember(dt1,dt2)
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR.

%   Copyright 2014 The MathWorks, Inc.

[aData,bData] = datetime.compareUtil(a,b);

if nargout < 2
    lia = ismember(aData,bData,varargin{:});
else
    [lia,locb] = ismember(aData,bData,varargin{:});
end

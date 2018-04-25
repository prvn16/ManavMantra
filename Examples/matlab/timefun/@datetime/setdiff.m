function [c,ia] = setdiff(a,b,varargin)
%SETDIFF Find datetimes that occur in one array but not in another.
%   C = SETDIFF(A,B) for datetime arrays A and B, returns the values in A that
%   are not in B with no repetitions. C is a vector sorted in ascending order.
%
%   A or B can also be a datetime string or a cell array of datetime strings.
%
%   C = SETDIFF(A,B,'rows') for datetime matrices A and B with the same number
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
%   [C,IA] = SETDIFF(A,B,'stable') for datetime arrays A and B, returns the
%   values of C in the order that they appear in A, while SETDIFF(A,B,'sorted')
%   returns the values of C in sorted order.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while SETDIFF(A,B,'rows','sorted') returns the
%   rows of C in sorted order.
%
%   Example:
%
%      % Create two arrays of datetimes.
%      dt1 = datetime(2015,10,1,0:4,0,0)
%      dt2 = datetime(2015,10,1,2:2:6,0,0)
%
%      % Find the difference between sets.
%      setdiff(dt1,dt2)
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.

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
[aData,bData,c] = datetime.compareUtil(a,b);

if nargout < 2
    cData = setdiff(aData,bData,varargin{:});
    if sorted
        cData = setMembershipSort(cData,rows);
    end
else
    [cData,ia] = setdiff(aData,bData,varargin{:});
    if sorted
        [cData,ia] = setMembershipSort(cData,ia,rows);
    end
end
c.data = cData;

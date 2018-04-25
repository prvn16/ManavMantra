function [c,ia,ib] = setxor(a,b,varargin)
%SETXOR Find datetimes that occur in one or the other of two arrays, but not both.
%   C = SETXOR(A,B) for datetime arrays A and B, returns the values that are not
%   in the intersection of A and B with no repetitions. C is a vector sorted in
%   ascending order.
%
%   A or B can also be a datetime string or a cell array of datetime strings.
%
%   C = SETXOR(A,B,'rows') for datetime matrices A and B with the same number of
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
%   [C,IA,IB] = SETXOR(A,B,'stable') for datetime arrays A and B, returns the
%   values of C in the same order that they appear in A and in B, while
%   SETXOR(A,B,'sorted') returns the values of C in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A and in B, while SETXOR(A,B,'rows','sorted')
%   returns the rows of C in sorted order.
%
%   Example:
%
%      % Create two arrays of datetimes.
%      dt1 = datetime(2015,10,1,0:4,0,0)
%      dt2 = datetime(2015,10,1,2:2:6,0,0)
%
%      % Find the datetimes that are only in dt1 or dt2, not both.
%      setxor(dt1,dt2)
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

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
    cData = setxor(aData,bData,varargin{:});
    if sorted
        cData = setMembershipSort(cData,rows);
    end
else
    [cData,ia,ib] = setxor(aData,bData,varargin{:});
    if sorted
        cData = setMembershipSort(cData,rows);
        [~,ia] = setMembershipSort(aData(ia),ia,rows);
        [~,ib] = setMembershipSort(bData(ib),ib,rows);
    end
end


c.data = cData;

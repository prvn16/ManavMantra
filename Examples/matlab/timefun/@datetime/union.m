function [c,ia,ib] = union(a,b,varargin)
%UNION Find datetimes that occur in either of two arrays.
%   C = UNION(A,B) for datetime arrays A and B, returns the combined values of
%   the two arrays with no repetitions.  C is a vector sorted in ascending
%   order.
%
%   A or B can also be a datetime string or a cell array of datetime strings.
%  
%   C = UNION(A,B,'rows') for datetime matrices A and B with the same number of
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
%   [C,IA,IB] = UNION(A,B,'stable') for datetime arrays A and B, returns the
%   values of C in the same order that they appear in A and in B, while
%   UNION(A,B,'sorted') returns the values of C in sorted order.
% 
%   [C,IA,IB] = UNION(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A and in B, while UNION(A,B,'rows','sorted')
%   returns the rows of C in sorted order.
%
%   Example:
%
%      % Create two arrays of datetimes.
%      dt1 = datetime(2015,10,1,0:4,0,0)
%      dt2 = datetime(2015,10,1,2:2:6,0,0)
%
%      % Find the union of dt1 and dt2.
%      union(dt1,dt2)
%
%      % Find the union of dt1 and dt2 and return the index vectors.
%      [C,IA,IB] = union(dt1,dt2)
%
%      % Construct the union from IA and IB
%      U = [dt1(IA) dt2(IB)]
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 2014 The MathWorks, Inc.

sorted = (nargin < 3) || any(strcmp(varargin,'sorted'));
rows = any(strcmp(varargin,'rows'));

[aData,bData,c] = datetime.compareUtil(a,b);

if nargout < 2
    cData = union(aData,bData,varargin{:});
    if sorted
        cData = setMembershipSort(cData,rows);
    end
else
    [cData,ia,ib] = union(aData,bData,varargin{:});
    if sorted
        cData = setMembershipSort(cData,rows);
        [~,ia] = setMembershipSort(aData(ia),ia,rows);
        [~,ib] = setMembershipSort(bData(ib),ib,rows);
    end
end

c.data = cData;

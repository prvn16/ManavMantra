function [data,i,j,reord] = setMembershipSort(data,i,j,rows)
% This function is called by set membership functions
% (unique,intersect,setdiff,setxor) to handle datetimes pre-1970, with
% fractional seconds below milliseconds. The default sort behavior used by
% base unique does not work correctly in such cases. Need to resort with
% ComparisonMethod real.
%   Copyright 2014-2017 The MathWorks, Inc.

if nargin == 2
    rows = i;
elseif nargin == 3
    rows = j;
end

if rows
    [data,reord] = sortrows(data,'ComparisonMethod','real');
else
    [data,reord] = sort(data,'ComparisonMethod','real');
end

if nargin == 2 % [data,reord] = setMembershipSort(data,rows)
    i = reord;
elseif nargin == 3 % [data,i,reord] = setMembershipSort(data,i,rows)
    i(:) = i(reord);
    j = reord;
else % [data,i,j,reord] = setMembershipSort(data,i,j,rows)
    i(:) = i(reord);
    j(:) = j(reord);
end

function [c,ia] = setdiff(a,b,varargin)
%SETDIFF Find rows that occur in one table but not in another.
%   C = SETDIFF(A,B) for tables A and B, returns the set of rows that are in A
%   but not in B, with repetitions removed.  The rows in the table C are in
%   sorted order.
%
%   A and B must have the same variable names, except for order.  SETDIFF(A,B)
%   works on complete rows of A and B, considering all of their variables.  To
%   find the set difference with respect to a subset of those variables, use
%   column subscripting such as SETDIFF(A(:,VARS),B(:,VARS)), where VARS is a
%   positive integer, a vector of positive integers, a variable name, a cell
%   array of variable names, or a logical vector.
%
%   SETDIFF does not take row names of tables into account.  Two rows that
%   have the same values but different names are considered equal. However,
%   when A and B are timetables, SETDIFF does take the row times into
%   account in determining equal rows, and row times are used as the first
%   sorting variable.
% 
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that C = A(IA,:).
%   If there are repeated rows in A, then the index of the first occurrence is
%   returned.
%
%   [C,...] = SETDIFF(A,B,'stable') returns the rows in C in the same order that
%   they appear in A.
%
%   [C,...] = SETDIFF(A,B,'sorted') returns the rows in C in sorted order.  This
%   is the default behavior.
%
%   See also UNION, INTERSECT, SETXOR, ISMEMBER,
%            UNIQUE, SORTROWS.

%   Copyright 2012-2016 The MathWorks, Inc.

if nargin < 3
    flag = 'sorted';
else
    narginchk(2,5); % high=5, to let setmembershipFlagChecks sort flags out
    flag = tabular.setmembershipFlagChecks(varargin);
end

[ainds,binds] = tabular.table2midx(a,b);

% Calling setdiff with either 'sorted' or 'stable' gives occurrence='first'
[~,ia] = setdiff(ainds,binds,flag,'rows');

c = subsrefParens(a,substruct('()',{ia ':'}));

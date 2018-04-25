function [c,ia,ib] = intersect(a,b,varargin)
%INTERSECT Find rows common to two tables.
%   C = INTERSECT(A,B) for tables A and B, returns the common set of rows from
%   the two tables, with repetitions removed.  The rows in the table C are in
%   sorted order.
%
%   A and B must have the same variable names, except for order.  INTERSECT(A,B)
%   works on complete rows of A and B, considering all of their variables.  To
%   find the intersection with respect to a subset of those variables, use
%   column subscripting such as INTERSECT(A(:,VARS),B(:,VARS)), where VARS is a
%   positive integer, a vector of positive integers, a variable name, a cell
%   array of variable names, or a logical vector.
%
%   INTERSECT does not take row names of tables into account.  Two rows
%   that have the same values but different names are considered equal.
%   However, when A and B are timetables, INTERSECT does take the row times
%   into account in determining equal rows, and row times are used as the
%   first sorting variable.
% 
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB such that C
%   = A(IA,:) and C = B(IB,:).  If there are repeated rows in A or B, then the
%   index of the first occurrence is returned.
%
%   [C,...] = INTERSECT(A,B,'stable') returns the rows in C in the same order
%   that they appear in A.
%
%   [C,...] = INTERSECT(A,B,'sorted') returns the rows in C in sorted order.
%   This is the default behavior.
%
%   See also UNION, SETDIFF, SETXOR, ISMEMBER,
%            UNIQUE, SORTROWS.

%   Copyright 2012-2016 The MathWorks, Inc.

if nargin < 3
    flag = 'sorted';
else
    narginchk(2,5); % high=5, to let setmembershipFlagChecks sort flags out
    flag = tabular.setmembershipFlagChecks(varargin);
end

[ainds,binds] = tabular.table2midx(a,b);

% Calling intersect with either 'sorted' or 'stable' gives occurrence='first'
[~,ia,ib] = intersect(ainds,binds,flag,'rows');

c = subsrefParens(a,substruct('()',{ia ':'}));

% Use b's per-row, per-var, and per-array property values where a's were empty.
if ~a.rowDim.hasLabels && b.rowDim.hasLabels
    c.rowDim = b.rowDim.selectFrom(ib);
end
c.varDim = a.varDim.mergeProps(b.varDim,1:b.varDim.length);
c.arrayProps = tabular.mergeArrayProps(a.arrayProps,b.arrayProps);

function [b,idx] = topkrows(a,k,vars,sortMode,varargin)
%TOPKROWS Top K sorted rows of timetable.
%   B = TOPKROWS(A,K) returns the top K rows of A sorted in descending
%   order by time.
%
%   B = TOPKROWS(A,K,VARS) returns the top K rows sorted by the variables
%   specified by VARS. VARS can be a positive integer, a vector of positive
%   integers, a variable name, a cell array containing one or more variable
%   names, or a logical vector. VARS can also include the name of the row
%   dimension, i.e. A.Properties.DimensionNames{1}, to sort by row names as
%   well as by data variables. By default, the row dimension name is
%   'Time'.
%
%   B = TOPKROWS(A,K,VARS,DIRECTION) also specifies the sort direction(s).
%   DIRECTION can be:
%       'descend' - (default) Sorts in descending order.
%        'ascend' - Sorts in ascending order.
%
%   TOPKROWS sorts A in ascending or descending order according to all
%   variables specified by VARS. Use a different direction for each
%   variable by specifying DIRECTION as a cell array. For example,
%   TOPKROWS(A,5,[2 3],{'ascend' 'descend'}). Specify VARS as 1:SIZE(A,2)
%   to sort using all variables.
%
%   B = TOPKROWS(A,K,VARS,DIRECTION,'ComparisonMethod',C) specifies how to
%   compare complex numbers. The comparison method C can be:
%       'auto' - (default) Compares real numbers according to 'real', and
%                complex numbers according to 'abs'.
%       'real' - Compares according to REAL(A). Elements with equal real
%                parts are then sorted by IMAG(A).
%        'abs' - Compares according to ABS(A). Elements with equal
%                magnitudes are then sorted by ANGLE(A).
%
%   [B,I] = TOPKROWS(A,...) also returns an index vector I that describes
%   the order of the K selected rows such that B = A(I,:).
%
%   See also SORTROWS.


%   Copyright 2017 The MathWorks, Inc.

if nargin < 3
    vars = a.metaDim.labels(1);
end

if nargin < 4
    [b,idx] = topkrows@tabular(a,k,vars);
else
    [b,idx] = topkrows@tabular(a,k,vars,sortMode,varargin{:});
end

function a = vertcat(varargin)
%VERTCAT Vertical concatenation for categorical arrays.
%   C = VERTCAT(A, B, ...) vertically concatenates the categorical arrays
%   A, B, ... .  For matrices, all inputs must have the same number of
%   columns. For N-D arrays, all inputs must have the same sizes except in
%   the first dimension.  Any of A, B, ... may also be cell arrays of
%   character vectors or scalar strings.
%
%   C = VERTCAT(A,B) is called for the syntax [A; B].
%
%   If all the input arrays are ordinal categorical arrays, they must have the
%   same sets of categories, including category order.  If none of the input
%   arrays are ordinal, they need not have the same sets of categories.  In this
%   case, C's categories are the union of the input array categories. However,
%   categorical arrays that are not ordinal but are protected may only be
%   concatenated with other arrays that have the same categories.
%
%   See also CAT, HORZCAT.

%   Copyright 2006-2016 The MathWorks, Inc.

a = cat(1,varargin{:});

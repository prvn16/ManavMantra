function [c,i] = setdiff(a,b,varargin)
%SETDIFF Set difference for categorical arrays.
%   C = SETDIFF(A,B) for categorical arrays A and B, returns the values in
%   A that are not in B with no repetitions. Either A or B may also be a
%   string scalar or character vector. C is sorted.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order. If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names. In this case, C's categories are the sorted union of A's and
%   B's categories.
%
%   C = SETDIFF(A,B,'rows') for categorical matrices A and B with the same
%   number of columns, returns the rows from A that are not in B. Either A
%   or B may also be a string scalar or  a cell array of character vectors.
%   The rows of the matrix C are in sorted order.
%
%   [C,IA] = SETDIFF(A,B) also returns an index vector IA such that C = A(IA).
%   If A is a row vector, then C will be a row vector as well, otherwise C will
%   be a column vector. IA is a column vector. If there are repeated values in A
%   that are not in B, then the index of the first occurrence of each repeated
%   value is returned.
%
%   [C,IA] = SETDIFF(A,B,'rows') also returns an index vector IA such that
%   C = A(IA,:).
%
%   [C,IA] = SETDIFF(A,B,'stable') for categorical arrays A and B, returns the
%   values of C in the order that they appear in A, while SETDIFF(A,B,'sorted')
%   returns the values of C in sorted order.
%
%   [C,IA] = SETDIFF(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A, while SETDIFF(A,B,'rows','sorted') returns the
%   rows of C in sorted order.
% 
%   SETDIFF(A,B,'legacy') and SETDIFF(A,B,'rows','legacy') preserve the behavior
%   of the SETDIFF function from R2012b and prior releases.
%
%   See also UNIQUE, UNION, INTERSECT, SETXOR, ISMEMBER.

%   Copyright 2006-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings

narginchk(2,Inf);

if ~isa(a,'categorical') || ~isa(b,'categorical')
    if isCharString(a) || isCharStrings(a) || (isstring(a) && isscalar(a))
        a = strings2categorical(a,b);
    elseif isCharString(b) || isCharStrings(b) || (isstring(b) && isscalar(b))
        b = strings2categorical(b,a);
    else
        error(message('MATLAB:categorical:setmembership:TypeMismatch','SETDIFF'));
    end
elseif a.isOrdinal ~= b.isOrdinal
    error(message('MATLAB:categorical:setmembership:OrdinalMismatch','SETDIFF'));
end
isOrdinal = a.isOrdinal;
a = a(:); b = b(:);

acodes = a.codes;
cnames = a.categoryNames;
if isequal(b.categoryNames,cnames)
    bcodes = b.codes;
elseif ~isOrdinal
    % Convert b to a's categories, possibly expanding the set of categories
    % if neither array is protected.
    [bcodes,cnames] = convertCodes(b.codes,b.categoryNames,cnames,a.isProtected,b.isProtected);
else
    error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
end

if nargin > 2 && ~isCharStrings(varargin)
    error(message('MATLAB:categorical:setmembership:UnknownInput'));
end

% Make sure acodes and bcodes have the same integer class, but if either
% contains <undefined>, cast to float to leverage builtin's NaN handling
[acodes, bcodes] = categorical.castCodesForBuiltins(acodes,bcodes);

try
    if nargout > 1
        [ccodes,i] = setdiff(acodes,bcodes,varargin{:});
    else
        ccodes = setdiff(acodes,bcodes,varargin{:});
    end
catch ME
    throw(ME);
end

if isfloat(ccodes)
    % Cast back to integer codes, including NaN -> <undefined>
    ccodes = categorical.castCodes(ccodes,length(cnames));
end
c = a; % preserve subclass
c.codes = ccodes;
c.categoryNames = cnames;

function [c,ia,ib] = setxor(a,b,varargin)
%SETXOR Set exclusive-or for categorical arrays.
%   C = SETXOR(A,B) for categorical arrays A and B, returns the values that
%   are not in the intersection of A and B with no repetitions. Either A or
%   B may also be a string scalar or character vector. C is sorted.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order. If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names. In this case, C's categories are the sorted union of A's and
%   B's categories.
%
%   C = SETXOR(A,B,'rows') for categorical matrices A and B with the same
%   number of columns, returns the rows that are not in the intersection of
%   A and B. Either A or B may also be a string scalar or character vector.
%   The rows of the matrix C are in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that C is
%   a sorted combination of the values A(IA) and B(IB). If A and B are row
%   vectors, then C will be a row vector as well, otherwise C will be a column
%   vector. IA and IB are column vectors. If there are repeated values that are
%   not in the intersection of A and B, then the index of the first occurrence
%   of each repeated value is returned.
%
%   [C,IA,IB] = SETXOR(A,B,'rows') also returns index vectors IA and IB 
%   such that C is the sorted combination of rows A(IA,:) and B(IB,:).
%
%   [C,IA,IB] = SETXOR(A,B,'stable') for categorical arrays A and B, returns
%   the values of C in the same order that they appear in A and in B, while
%   SETXOR(A,B,'sorted') returns the values of C in sorted order.
%
%   [C,IA,IB] = SETXOR(A,B,'rows','stable') returns the rows of C in the same
%   order that they appear in A and in B, while SETXOR(A,B,'rows','sorted')
%   returns the rows of C in sorted order.
% 
%   SETXOR(A,B,'legacy') and SETXOR(A,B,'rows','legacy') preserve the behavior
%   of the SETXOR function from R2012b and prior releases.
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, ISMEMBER.

%   Copyright 2006-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings

narginchk(2,Inf);

if ~isa(a,'categorical') || ~isa(b,'categorical')
    if isCharString(a) || isCharStrings(a)  || (isstring(a) && isscalar(a))
        a = strings2categorical(a,b);
    elseif isCharString(b) || isCharStrings(b) || (isstring(b) && isscalar(b))
        b = strings2categorical(b,a);
    else
        error(message('MATLAB:categorical:setmembership:TypeMismatch','SETXOR'));
    end
elseif a.isOrdinal ~= b.isOrdinal
    error(message('MATLAB:categorical:setmembership:OrdinalMismatch','SETXOR'));
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
        [ccodes,ia,ib] = setxor(acodes,bcodes,varargin{:});
    else
        ccodes = setxor(acodes,bcodes,varargin{:});
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

function c = times(a,b)
%TIMES Create a categorical array from the Cartesian product of existing categories.
%   C = TIMES(A,B) returns a categorical array whose categories are the
%   Cartesian product of the sets of categories in A and B, and whose
%   elements are each from the category formed from the combination of the
%   categories of the corresponding elements of A and B.  Either A or B may
%   also be a string scalar or character vector.
%
%   C = TIMES(A,B) is called for the syntax A .* B.
%
%   See also CATEGORICAL/CATEGORICAL.

%   Copyright 2006-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharStrings
import matlab.internal.datatypes.isCharString

% Accept 1 as a valid "identity element".
if isnumeric(a) && isequal(a,1)
    c = b;
    return;
elseif isnumeric(b) && isequal(b,1)
    c = a;
    return;
elseif ~isa(a,'categorical') || ~isa(b,'categorical')
    if isCharString(a) || isCharStrings(a) || (isstring(a) && isscalar(a))% && isa(b,'categorical')
        [acodes, anames] = strings2codes(a);
        if ischar(anames), anames={anames}; end
        bnames = b.categoryNames;
        bcodes = b.codes;
        c = b;
        c.isOrdinal = b.isOrdinal;
        c.isProtected = b.isProtected;
    elseif isCharString(b) || isCharStrings(b) || (isstring(b) && isscalar(b))% && isa(a,'categorical')
        [bcodes, bnames] = strings2codes(b);
        if ischar(bnames), bnames={bnames}; end
        anames = a.categoryNames;
        acodes = a.codes;
        c = a;
        c.isOrdinal = a.isOrdinal;
        c.isProtected = a.isProtected;
    else
        error(message('MATLAB:categorical:times:TypeMismatch'));
    end
else
    anames = a.categoryNames; acodes = a.codes;
    bnames = b.categoryNames; bcodes = b.codes;
    c = a;
    c.isOrdinal = (a.isOrdinal && b.isOrdinal);
    c.isProtected = (a.isProtected || b.isProtected);
end

na = length(anames);
nb = length(bnames);
numCats = na*nb;
if numCats > categorical.maxNumCategories
    error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
end

anames = repmat(anames(:)',nb,1); anames = anames(:);
bnames = repmat(bnames(:)',1,na); bnames = bnames(:);
c.categoryNames = strcat(anames,{' '},bnames);
acodes = categorical.castCodes(acodes, numCats);
bcodes = categorical.castCodes(bcodes, numCats);
c.codes = bcodes + nb*(acodes-1);
c.codes( acodes==c.undefCode | bcodes==c.undefCode ) = c.undefCode; % undefined in either -> undefined in result


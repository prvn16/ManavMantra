function [acodes,bcodes,prototype] = reconcileCategories(a,b,requireOrdinal)
%RECONCILECATEGORIES Utility for logical comparison of categorical arrays.

%   Copyright 2013-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharStrings

if isa(a,'categorical') && isa(b,'categorical')
    if requireOrdinal && (~a.isOrdinal || ~b.isOrdinal)
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    elseif a.isOrdinal ~= b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:OrdinalMismatchComparison'));
    end
    acodes = a.codes;
    anames = a.categoryNames;
    bnames = b.categoryNames;
    if isequal(anames,bnames)
        bcodes = b.codes;
        % Identical category names => same codes class => no cast needed for acodes
    elseif a.isOrdinal % && b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidOrdinalComparison'));
    else
        [bcodes,bnames] = convertCodes(b.codes,bnames,anames,a.isProtected,b.isProtected);
        if length(bnames) > length(anames)
            acodes = cast(acodes,'like',bcodes); % bcodes is always a higher or equivalent integer class as acodes
        end
    end
    prototype = a; % preserve subclass
    
elseif ischar(b) && (isrow(b) || isequal(b,'')) || isCharStrings(b) || (isstring(b) && isscalar(b)) % && isa(a,'categorical')
    if requireOrdinal && ~a.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    end
    acodes = a.codes;
    anames = a.categoryNames;
    [ib,ub] = strings2codes(b);
    [bcodes,bnames] = convertCodes(ib,ub,anames,a.isProtected,false);
    if length(bnames) > length(anames)
        acodes = cast(acodes,'like',bcodes); % bcodes is always a higher or equivalent integer class as acodes
    end
    prototype = a; % preserve subclass
    
elseif ischar(a) && (isrow(a) || isequal(a,'')) || isCharStrings(a) || (isstring(a) && isscalar(a)) % && isa(b,'categorical')
    if requireOrdinal && ~b.isOrdinal
        throwAsCaller(msg2exception('MATLAB:categorical:NotOrdinal'));
    end
    bcodes = b.codes;
    bnames = b.categoryNames;
    [ia,ua] = strings2codes(a);
    [acodes,anames] = convertCodes(ia,ua,bnames,b.isProtected,false);
    if length(anames) > length(bnames)
        bcodes = cast(bcodes,'like',acodes); % acodes is always a higher or equivalent integer class as bcodes
    end
    prototype = b; % preserve subclass

else
    throwAsCaller(msg2exception('MATLAB:categorical:InvalidComparisonTypes'));
end

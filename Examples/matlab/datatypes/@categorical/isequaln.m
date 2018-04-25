function t = isequaln(varargin)
%ISEQUALN True if categorical arrays are equal, treating undefined elements as equal.
%   TF = ISEQUALN(A,B) returns logical 1 (true) if the categorical arrays A
%   and B are the same size and contain the same values or corresponding
%   undefined elements, and logical 0 (false) otherwise.  Either A or B may
%   also be a string scalar or character vector.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order.  If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the test is performed by comparing the
%   category names of each pair of elements.
%
%   TF = ISEQUALN(A,B,C,...) returns logical 1 (true) if all the input arguments
%   are equal.
%
%   Use ISEQUAL to treat undefined elements as unequal.
%
%   See also ISEQUAL, EQ, CATEGORIES.

%   Copyright 2013-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings

narginchk(2,Inf);

a = varargin{1};
if isa(a,'categorical')
    % Other inputs that are text will be converted to be 'like' a.
else
    % Find the first "real" categorical as a prototype for converting
    % character vectors.
    prototype = varargin{find(cellfun(@(x)isa(x,'categorical'),varargin),1,'first')};
    if isCharString(a) || isCharStrings(a) || (isstring(a) && isscalar(a))
        a = strings2categorical(a,prototype);
    else
        t = false; return
    end
end

isOrdinal = a.isOrdinal;
anames = a.categoryNames;
acodes = a.codes;

for i = 2:nargin
    b = varargin{i};
    
    if isa(b,'categorical')
        if b.isOrdinal ~= isOrdinal
            t = false; return
        elseif isequal(b.categoryNames,anames)
            bcodes = b.codes;
        elseif ~isOrdinal
            % Get a's codes for b's data, ignoring protectedness.
            bcodes = convertCodes(b.codes,b.categoryNames,anames);
        else
            t = false; return
        end
    elseif isCharString(b) || isCharStrings(b) || (isstring(b) && isscalar(b))
        [ib,ub] = strings2codes(b);
        bcodes = convertCodes(ib,ub,anames);
    elseif isa(b, 'missing')
        bcodes = zeros(size(b), 'uint8');
    else
        t = false; return
    end
    
    % Undefined elements in a will match undefined elements in b, both
    % codes are 0. Don't need to worry if acodes and bcodes are of different
    % type because isequal accepts any combination of numerics
    t = isequal(bcodes,acodes);
    
    if ~t, break; end
end

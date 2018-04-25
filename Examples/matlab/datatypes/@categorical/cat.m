function a = cat(dim,varargin)
%CAT Concatenate categorical arrays.
%   C = CAT(DIM, A, B, ...) concatenates the categorical arrays A, B, ...
%   along dimension DIM.  All inputs must have the same size except along
%   dimension DIM.  Any of A, B, ... may also be a cell arrays of character
%   vectors or scalar strings.
%
%   If all the input arrays are ordinal categorical arrays, they must have the
%   same sets of categories, including category order.  If none of the input
%   arrays are ordinal, they need not have the same sets of categories.  In this
%   case, C's categories are the union of the input array categories. However,
%   categorical arrays that are not ordinal but are protected may only be
%   concatenated with other arrays that have the same categories.
%
%   See also HORZCAT, VERTCAT.

%   Copyright 2006-2017 The MathWorks, Inc.

import matlab.internal.datatypes.isCharStrings

% Start out the concatenation with the first array. Find the first
% "real" categorical as a prototype for converting cell arrays of character
% vectors.
a = varargin{1};
if isa(a,'categorical')
    prototype = a;
else
    % This is expensive if nargin is large, so only do it if necessary.
    prototype = varargin{find(cellfun(@(x)isa(x,'categorical'),varargin),1,'first')};
    
    % The first array needs to be converted to categorical.
    if isnumeric(a) && isequal(a,[])
        a = prototype; a.codes = a.codes([]); % empty 'like' a.codes
    elseif isCharStrings(a) || (isstring(a) && isscalar(a))
        a = strings2categorical(a,prototype);
    elseif isa(a, 'missing')
        is = zeros(size(a), 'uint8');
        a = prototype;
        [a.codes, a.categoryNames] = convertCodes(is, {}, a.categoryNames);
    elseif iscell(a)
        error(message('MATLAB:categorical:cat:TypeMismatchCell'));
    else
        error(message('MATLAB:categorical:cat:TypeMismatch',class(a)));
    end
end
% The inputs must be all ordinal or not, so need only save one setting.
isOrdinal = prototype.isOrdinal;

for i = 2:nargin-1
    b = varargin{i};

    if isa(b,'categorical')
        if b.isOrdinal ~= isOrdinal
            error(message('MATLAB:categorical:OrdinalMismatchConcatenate'));
        end
    elseif isnumeric(b) && isequal(b,[])
        % Accept [] as a valid "identity element" for either arg.
        continue; % completely ignore this input
    else %  ~isa(b,'categorical')
        if isCharStrings(b) || (isstring(b) && isscalar(b))
            b = strings2categorical(b,prototype);
        elseif isa(b, 'missing')
            is = zeros(size(b), 'uint8');
            b = prototype;
            [b.codes, b.categoryNames] = convertCodes(is, {}, b.categoryNames);
        elseif iscell(b)
            error(message('MATLAB:categorical:cat:TypeMismatchCell'));
        else
            error(message('MATLAB:categorical:cat:TypeMismatch',class(b)));
        end
    end
    if isequal(a.categoryNames,b.categoryNames)
        % If the categoryNames are identical, the internal codes are of the same class
        acodes = a.codes;
        bcodes = b.codes;
    elseif ~isOrdinal
        % Convert b to a's categories, possibly expanding the set of categories
        % if neither array is protected (bcodes & acodes will be casted to
        % an appropriate class to handle the expanded range).
        [bcodes,a.categoryNames] = convertCodes(b.codes,b.categoryNames,a.categoryNames,a.isProtected,b.isProtected);
        acodes = cast(a.codes, 'like', bcodes); % bcodes is always a higher or equivalent integer class as acodes
    else
        error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
    end
    a.isProtected = a.isProtected || b.isProtected;

    try
        acodes = cat(dim, acodes, bcodes);
        a.codes = acodes; % acodes and bcodes are the same correct type by now, don't need a cast
    catch ME
        throw(ME);
    end
end

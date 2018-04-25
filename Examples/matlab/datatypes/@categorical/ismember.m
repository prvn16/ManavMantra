function [tf,loc] = ismember(a,b,varargin)
%ISMEMBER True for elements of a categorical array in a set.
%   LIA = ISMEMBER(A,B) for categorical arrays A and B, returns a logical array
%   of the same size as A containing true where the elements of A are in B and
%   false otherwise. A or B may also be a category name or a cell array of
%   character vectors containing category names.
%
%   If A and B are both ordinal, they must have the same sets of categories,
%   including their order. If neither A nor B are ordinal, they need not have
%   the same sets of categories, and the comparison is performed using the
%   category names.
%
%   LIA = ISMEMBER(A,B,'rows') for categorical matrices A and B with the
%   same number of columns, returns a logical vector containing true where
%   the rows of A are also rows of B and false otherwise. A or B may also
%   be a string scalar or cell array of character vectors containing
%   category names.
%
%   [LIA,LOCB] = ISMEMBER(A,B) also returns an index array LOCB containing the
%   lowest absolute index in B for each element in A which is a member of B
%   and 0 if there is no such index.
%
%   [LIA,LOCB] = ISMEMBER(A,B,'rows') also returns an index vector LOCB
%   containing the lowest absolute index in B for each row in A which is a
%   member of B and 0 if there is no such index.
% 
%   ISMEMBER(A,B,'legacy') and ISMEMBER(A,B,'rows','legacy') preserve the
%   behavior of the ISMEMBER function from R2012b and prior releases.
%
%   See also ISCATEGORY, UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR.

%   Copyright 2006-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings

narginchk(2,Inf);

if isa(a,'categorical')
    acodes = a.codes;
    if isa(b,'categorical')
        if a.isOrdinal ~= b.isOrdinal
            error(message('MATLAB:categorical:ismember:OrdinalMismatch'));
        elseif a.isOrdinal && ~isequal(a.categoryNames,b.categoryNames)
            error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
        end
        % Convert b to a's categories
        bcodes = convertCodes(b.codes,b.categoryNames,a.categoryNames);
        acodes = cast(acodes, 'like', bcodes); % bcodes is always a higher or equivalent integer class as acodes
        b_invalidCode = invalidCode(bcodes);
    else
        if isCharString(b)
            % leave as a character vector
        elseif isstring(b) && isscalar(b)
            if ~ismissing(b)
                % convert scalar string to char for category name
                b = char(b);
            else
                % missing strings map to the undefined category but can't
                % convert to char, so replace with ''.
                b = '';
            end
        elseif ~isCharStrings(b)
            error(message('MATLAB:categorical:ismember:TypeMismatch'));
        end
        [~,bcodes] = ismember(strtrim(b),a.categoryNames);
        b_invalidCode = invalidCode(acodes); % bcodes is a subset of acodes
    end
else % ~isa(a,'categorical') && isa(b,'categorical')
    if isCharString(a)
        % leave as a character vector
    elseif isstring(a) && isscalar(a) 
        if ~ismissing(a)
            % Convert scalar string to char for category name.
            a = char(a);
        else
            % The missing strings map to the undefined category, but it
            % can't convert to char, so replace with ''.
            a = '';
        end
    elseif ~isCharStrings(a)
        error(message('MATLAB:categorical:ismember:TypeMismatch'));
    end
    [~,acodes] = ismember(strtrim(a),b.categoryNames);
    bcodes = b.codes;
    b_invalidCode = invalidCode(bcodes); % acodes is a subset of bcodes
end

if nargin > 2 && ~isCharStrings(varargin)
    error(message('MATLAB:categorical:setmembership:UnknownInput'));
end

bcodes(bcodes==categorical.undefCode) = b_invalidCode; % prevent <undefined> in a and b from matching
if nargout < 2
    tf = ismember(acodes,bcodes,varargin{:});
else
    [tf,loc] = ismember(acodes,bcodes,varargin{:});
end

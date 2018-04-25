function a = subsasgn(a,s,b)
%SUBSASGN Subscripted assignment for a categorical array.
%     A = SUBSASGN(A,S,B) is called for the syntax A(I)=B.  S is a structure
%     array with the fields:
%         type -- Character vector containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array containing the actual subscripts.
%
%   See also CATEGORICAL/CATEGORICAL, SUBSREF.

%   Copyright 2006-2017 The MathWorks, Inc.

% Make sure nothing follows the () subscript
if ~isscalar(s)
    error(message('MATLAB:categorical:InvalidSubscripting'));
end

creating = isnumeric(a) && isequal(a,[]);
if creating % subscripted assignment to an array that doesn't exist
    a = b; % preserve the subclass
    a.codes = zeros(0,class(b.codes)); % account for the number of categories in b
end

anames = a.categoryNames;
numCatsOld = length(anames);

switch s.type
case '()'
    % Check numeric before builtin to short-circuit for performance and to
    % distinguish between '' and [].
    if isnumeric(b) && builtin('_isEmptySqrBrktLiteral',b)
        % Deleting elements, but the categories stay untouched. No need
        % to possibly downcast a.codes with castCodes.
        a.codes(s.subs{:}) = [];
        
    else
        if isa(b,'categorical')
            bcodes = b.codes;
            bnames = b.categoryNames;
            % If b is categorical, its ordinalness has to match a, and if they are
            % ordinal, their categories have to match.
            if a.isOrdinal ~= b.isOrdinal
                error(message('MATLAB:categorical:OrdinalMismatchAssign'));
            elseif isequal(anames,bnames)
                % Identical category names => same codes class => no cast needed for acodes
            else
                if a.isOrdinal
                    error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
                end
                % Convert b's codes to a's codes. a's new set of categories grows only by
                % the categories that are actually being assigned, and a never needs to
                % care about the others in b that are not assigned. 
                if isscalar(b)
                    % When b is an <undefined> scalar, bcodes is already correct in 
                    % a's codes (undefCode is the same in all categoricals) and no 
                    % conversion is needed; otherwise, we can behave as if it only
                    % has the one category, and conversion to a's codes is faster.
                    if bcodes ~= 0 % categorical.undefCode
                        [bcodes,anames] = convertCodesLocal(1,bnames{bcodes},anames,a.isProtected);
                    end
                else
                    [bcodes,anames] = convertCodesLocal(bcodes,bnames,anames,a.isProtected);
                end
            end
        elseif (ischar(b) && (isrow(b) || isequal(b,''))) || ...
            matlab.internal.datatypes.isCharStrings(b) || (isstring(b) && isscalar(b)) % inlined isCharString for performance
            [bcodes,bnames] = strings2codes(b);
            [bcodes,anames] = convertCodesLocal(bcodes,bnames,anames,a.isProtected);
        elseif isa(b, 'missing')
            bcodes = zeros(size(b), 'uint8');
        else
            error(message('MATLAB:categorical:InvalidRHS', class(a)));
        end
        
        % Upcast a's codes if necessary to account for any new categories
        if length(anames) > numCatsOld
            a.codes = categorical.castCodes(a.codes,length(anames));
        end
        a.codes(s.subs{:}) = bcodes;
        a.categoryNames = anames;
    end
    
case '{}'
    error(message('MATLAB:categorical:CellAssignmentNotAllowed'))
    
case '.'
    error(message('MATLAB:categorical:FieldAssignmentNotAllowed'))
end


function [bcodes,anames] = convertCodesLocal(bcodes,bnames,anames,aprotect)
% This is a version of convertCodes modified for the specifics of subsasgn.
% Assigning from b into a, so:
% * Need to return updated category names for a, not b, and a's list is grown
%   only by the (new) categories from b that are actually being assigned,
%   ignoring those that are not being assigned
% * Don't care if b is protected
% * If a is protected, only care if the values actually being assigned are not
%   categories in a. Unused categories in b not in a don't matter.

try
    
    if ischar(bnames)
        ia = find(strcmp(bnames,anames));
        if isempty(ia)
            if aprotect
                throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
            end
            anames = [anames; bnames];
            bcodes = length(anames);
        else
            bcodes = ia;
        end

        numCats = length(anames);
        if numCats > categorical.maxNumCategories
            throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
        end
        % Leave bcodes as a scalar double, main subsasgn function assigns it into
        % an integer array, so no cast needed here.

    else % iscellstr(bnames)
        % Get a's codes for b's data.  Any elements of b that do not match a category of
        % a are assigned codes beyond a's range.
        [tf,ia] = ismember(bnames,anames);
        b2a = zeros(1,length(bnames)+1,categorical.defaultCodesClass);
        b2a = categorical.castCodes(b2a, length(anames)); % enough range to store ia, may upcast later
        b2a(2:end) = ia;

        % b has categories not present in a
        if ~all(tf)
            % Find b's categories that are actually being newly assigned into a.
            % Don't care about other categories in b but not in a.
            newlyAssigned(unique(bcodes(bcodes>0))) = true;
            newlyAssigned(tf) = false;

            % If a is protected we can't assign new categories.
            if any(newlyAssigned)
                if aprotect
                    throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
                end
                ib = find(newlyAssigned);
                numCats = length(anames) + length(ib);
                if numCats > categorical.maxNumCategories
                    throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
                end
                % Append new categories corresponding to b's extras, possibly upcasting b2a
                b2a = categorical.castCodes(b2a, numCats);
                b2a(ib+1) = length(anames) + (1:length(ib));
                anames = [anames; bnames(ib)];
            end
        end
        bcodes = reshape(b2a(bcodes+1),size(bcodes));
    end

catch me
    if aprotect && strcmp(me.identifier,'MATLAB:categorical:ProtectedForCombination')
        names = setdiff(bnames,anames);
        throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForAssign',names{1}));
    else
        throwAsCaller(me);
    end
end

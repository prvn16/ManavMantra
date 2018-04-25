function [bcodes,bnames] = convertCodes(bcodes,bnames,anames,aprotect,bprotect)
%CONVERTCODES Translate one categorical array's data to another's categories.

%   Copyright 2013-2015 The MathWorks, Inc.

if nargin < 5
    aprotect = false;
    bprotect = false;
end

if ischar(bnames) % b was one string, not a categorical or cellstr, so never protected
    ia = find(strcmp(bnames,anames));
    if isempty(ia);
        if aprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
        bnames = [anames; bnames];
        bcodes = length(bnames);
        numCats = length(bnames);
        if numCats > categorical.maxNumCategories
            throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
        end
    else
        bnames = anames;
        bcodes = ia;
        numCats = length(anames);
    end
    bcodes = categorical.castCodes(bcodes,numCats); % cast to int because callers rely on an integer class


else % iscellstr(bnames)
    % Get a's codes for b's data.  Any elements of b that do not match a category of
    % a are assigned codes beyond a's range.
    [tf,ia] = ismember(bnames,anames);
    b2a = zeros(1,length(bnames)+1,categorical.defaultCodesClass);
    b2a = categorical.castCodes(b2a, length(anames)); % enough range to store ia, may upcast later
    b2a(2:end) = ia;
    
    % a has more categories than b
    if nnz(ia) < length(anames) % any(ia(:) == categorical.undefCode)
        % If b is protected and a has more categories, can't convert.
        if bprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
    end
    
    % b has more categories than a
    if ~all(tf)
        % If a is protected and b has more categories, can't convert.
        if aprotect
            throwAsCaller(msg2exception('MATLAB:categorical:ProtectedForCombination'));
        end
        ib = find(~tf(:));
        numCats = length(anames) + length(ib);
        if numCats > categorical.maxNumCategories
            throwAsCaller(msg2exception('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
        end
        % Append new categories corresponding to b's extras, possibly upcasting b2a
        b2a = categorical.castCodes(b2a, numCats);
        b2a(ib+1) = length(anames) + (1:length(ib));
        bnames = [anames; bnames(ib)];
    else
        bnames = anames;
    end
    bcodes = reshape(b2a(bcodes+1),size(bcodes));
end

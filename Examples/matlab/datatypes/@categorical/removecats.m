function a = removecats(a,oldCategories)
%REMOVECATS Remove categories from a categorical array.
%   B = REMOVECATS(A) removes unused categories from the categorical array A,
%   that is, categories that not are actually present as the value of some
%   element of A.  B is a categorical array with the same size and values as A,
%   but whose set of categories may be smaller.
%
%   B = REMOVECATS(A,OLDCATEGORIES) removes the categories specified by
%   OLDCATEGORIES from the categorical array A.  OLDCATEGORIES is a
%   character vector or a cell array of character vectors. REMOVECATS
%   removes the categories, but does not remove elements. Elements of B
%   that correspond to elements of A whose values are in OLDCATEGORIES are
%   undefined.
%
%   See also CATEGORIES, ADDCATS, ISCATEGORY, MERGECATS, RENAMECATS, REORDERCATS, SETCATS.

%   Copyright 2013-2016 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLD'));
end

if nargin < 2
    % Find any unused codes in A.
    codehist = histc(a.codes(:),1:length(a.categoryNames));
    oldCodes = find(codehist == 0);
else
    oldCategories = checkCategoryNames(oldCategories,1); % remove any duplicates
    
    % Find the codes for the categories that will be dropped.
    [tf,oldCodes] = ismember(oldCategories,a.categoryNames);

    % Ignore anything in oldCategories that didn't match a category of A.
    oldCodes = oldCodes(tf);
    
    % Some elements of A may have become undefined.
end

% Set up a vector to map the existing categories to the new, reduced categories.
acodes = a.codes;
anames = a.categoryNames;
convert = 1:cast(length(anames),'like',acodes);

% Remove the old categories from A.
anames(oldCodes) = [];
a.categoryNames = anames;

% Translate the codes for the categories that haven't been dropped.
dropped = zeros(size(convert),'like',acodes);
dropped(oldCodes) = 1;
convert = convert - cumsum(dropped);
convert(dropped>0) = categorical.undefCode;
convert = [categorical.undefCode convert]; % there may be undefined elements in a.codes
acodes = reshape(convert(acodes+1),size(acodes)); % acodes has correct type because convert does
a.codes = categorical.castCodes(acodes,length(anames)); % possibly downcast acodes

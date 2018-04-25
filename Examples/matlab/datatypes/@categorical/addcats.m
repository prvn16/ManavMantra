function a = addcats(a,newCategories,varargin)
%ADDCATS Add categories to a categorical array.
%   B = ADDCATS(A,NEWCATEGORIES,'Before',WHERE) adds categories to the
%   categorical array A before the category specified by WHERE.
%   NEWCATEGORIES is a character vector or a cell array of character
%   vectors that specifies the new categories to be added.
%
%   B = ADDCATS(A,NEWCATEGORIES,'After',WHERE) adds categories to A after the
%   category specified by WHERE.
%
%   B = ADDCATS(A,NEWCATEGORIES) adds categories to the categorical array A at
%   the end of A's list of categories.  A may not be ordinal.
%
%   ADDCATS adds new categories to A, but does not modify the value of any of
%   its elements.  B does not contain any elements equal to the new categories
%   until you assign values from NEWCATEGORIES to some of B's elements.
%
%   See also CATEGORIES, REMOVECATS, ISCATEGORY, MERGECATS, RENAMECATS, REORDERCATS, SETCATS.

%   Copyright 2013-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEW,...'));
end

% Remove any duplicates in the new names, both within them and between them and
% the existing names, but leave the non-duplicates in their original order.
categories = a.categoryNames;
numExisting = length(categories);
newCategories = setdiff(checkCategoryNames(newCategories,0),categories,'stable');
numNew = length(newCategories);
if numExisting+numNew > categorical.maxNumCategories
    error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
end

if nargin < 3
    if isordinal(a)
        error(message('MATLAB:categorical:addcats:NoBeforeOrAfter'));
    end
    % Add the new categories onto the end of existing list.
    after = numExisting;
    categories = [categories; newCategories];
else
    pnames = {'Before' 'After'};
    dflts =  {     {}      {} };
    [before,after,supplied] = ...
        matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:}); %#ok<*PROP>
    if supplied.Before
        if supplied.After
            error(message('MATLAB:categorical:addcats:BeforeAndAfter'));
        elseif ~isCharString(before)
            error(message('MATLAB:categorical:addcats:InvalidCategoryName','BEFORE'));
        end
        ibefore = find(strcmp(before,categories));
        if isempty(ibefore)
            error(message('MATLAB:categorical:addcats:UnrecognizedCategory',before));
        end
        after = ibefore - 1;
        categories = [categories(1:after); newCategories; categories(after+1:end)];
    elseif supplied.After
        if ~isCharString(after)
            error(message('MATLAB:categorical:addcats:InvalidCategoryName','AFTER'));
        end
        iafter = find(strcmp(after,categories));
        if isempty(iafter)
            error(message('MATLAB:categorical:addcats:UnrecognizedCategory',after));
        end
        after = iafter;
        categories = [categories(1:after); newCategories; categories(after+1:end)];
    else
        after = numExisting;
        categories = [categories; newCategories];
    end
end

% Possibly upcast a's codes in advance to account for new categories
a.codes = categorical.castCodes(a.codes,length(categories));
a.categoryNames = categories;
if after < numExisting
    shift = (a.codes > after);
    a.codes(shift) = a.codes(shift) + numNew;
end

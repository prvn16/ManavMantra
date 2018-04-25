function a = setcats(a,names)
%SETCATS Set the categories of a categorical array.
%   B = SETCATS(A,NEWCATEGORIES) returns a categorical array B with
%   categories defined by NEWCATEGORIES and elements defined by categorical
%   array A. NEWCATEGORIES must be a character vector, or cell array of
%   character vectors. Elements of A whose categories are listed in
%   NEWCATEGORIES remain unchanged in B. Categories of A not listed in
%   NEWCATEGORIES are not present in B, and the associated elements in B
%   become undefined.
% 
%   The array B does not contain elements equal to categories listed in 
%   NEWCATEGORIES which were not categories of A until you assign values
%   from NEWCATEGORIES to some of B's elements.
% 
%   If you want to change the category names, use RENAMECATS.
% 
%   Example: 
%      % Create a categorical array
%      a = [3 2 1; 1 3 2; 2 1 3];
%      c = categorical(a,[1,2,3],{'red','black','blue'})
%
%      % Set new categories 
%      c = setcats(c,{'red','pink','blue'})
%
%      % Assign an element to be one of the new categories
%      c(3) = 'pink'
%
%   See also, CATEGORIES, ADDCATS, REMOVECATS, ISCATEGORY, MERGECATS,
%   REORDERCATS, RENAMECATS.

%   Copyright 2014-2016 The MathWorks, Inc.

if nargout == 0
    error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWCATEGORIES'));
end

names = checkCategoryNames(names,true);

a.codes = convertCodes(a.codes,a.categoryNames,names);
a.codes(a.codes > length(names)) = 0;
a.categoryNames = names;
end


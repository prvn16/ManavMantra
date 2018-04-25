function a = renamecats(a,oldNames,newNames)
%RENAMECATS Rename categories in a categorical array.
%   B = RENAMECATS(A,NAMES) renames the categories in the categorical array
%   A. NAMES is a character vector or a cell array of character vectors.
%
%   B = RENAMECATS(A,OLDNAMES,NEWNAMES) renames the categories specified in
%   OLDNAMES to the names specified in NEWNAMES.  OLDNAMES and NEWNAMES are
%   both a character vector or a cell array of character vector.
%
%   Example: 
%      % Create a categorical array
%      a = [3 2 1; 1 3 2; 2 1 3];
%      c = categorical(a,[1,2,3],{'red','black','blue'})
%
%      % Set new categories 
%      c = renamecats(c,{'red','blue','black'},{'red','blue','pink'})
%
%   See also CATEGORIES, ADDCATS, REMOVECATS, ISCATEGORY, MERGECATS, REORDERCATS, SETCATS.

%   Copyright 2013-2016 The MathWorks, Inc.

if nargout == 0
    if nargin < 3
        error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',NEWNAMES'));
    else
        error(message('MATLAB:categorical:NoLHS',upper(mfilename),upper(mfilename),',OLDNAMES,NEWNAMES'));
    end
end

oldNames = checkCategoryNames(oldNames,2); % error if duplicates

if nargin < 3
    newNames = oldNames; % shift inputs
    if length(newNames) ~= length(a.categoryNames)
        error(message('MATLAB:categorical:renamecats:IncorrectNumNames'));
    end
    a.categoryNames = newNames;
else
    newNames = checkCategoryNames(newNames,2); % error if duplicates
    if length(newNames) ~= length(oldNames)
        error(message('MATLAB:categorical:renamecats:IncorrectNumNamesPartial'));
    end
    [tf,locs] = ismember(oldNames,a.categoryNames);
    if ~all(tf)
        error(message('MATLAB:categorical:renamecats:InvalidNames'));
    end
    notlocs = true(size(a.categoryNames)); notlocs(locs) = false;
    tf = ismember(newNames,a.categoryNames(notlocs));
    if any(tf)
        i = find(tf,1,'first');
        error(message('MATLAB:categorical:renamecats:DuplicateNames',oldNames{i},newNames{i}));
    end
    a.categoryNames(locs) = newNames;
end

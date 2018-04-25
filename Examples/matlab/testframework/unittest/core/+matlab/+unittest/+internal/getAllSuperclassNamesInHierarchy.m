function allSuperClassNames = getAllSuperclassNamesInHierarchy(currentClass)
% The function is undocumented and may change in a future release.

% Copyright 2017 The MathWorks, Inc.

assert(isscalar(currentClass));
allMetaClasses = allSuperMetaClasses(currentClass);
allSuperClassNames = unique(string({allMetaClasses.Name}.'));
end

function mcs = allSuperMetaClasses(mc)
mcs = mc.SuperclassList;
for k = 1:length(mcs)
    mcs = [mcs; allSuperMetaClasses(mcs(k))]; %#ok<AGROW>
end
end
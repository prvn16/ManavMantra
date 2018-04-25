function tagMap = determineTagsFor(testClass, testMethods)
% This function is undocumented and may change in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

import matlab.unittest.internal.getAllTestCaseClassesInHierarchy;

tagMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
classes = getAllTestCaseClassesInHierarchy(testClass);

% Only pick up tags for a method's defining class and its superclasses.
for methodIdx = 1:numel(testMethods)
    method = testMethods(methodIdx);    
    ancestorClasses = classes(method.DefiningClass <= classes);    
    allTags = [{ancestorClasses.TestTags}, {method.TestTags}];
    rowTags = cellfun(@toRow, allTags, 'UniformOutput', false);
    tags = cellstr([{}, rowTags{:}]);
    tagMap(method.Name) = unique(tags);
end
end

function arr = toRow(arr)
arr = reshape(arr, 1, []);
end

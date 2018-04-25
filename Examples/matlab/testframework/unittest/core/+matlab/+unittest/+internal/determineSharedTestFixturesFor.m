function fixtures = determineSharedTestFixturesFor(testClass)
% This function is undocumented and may change in a future release.

% Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.getAllTestCaseClassesInHierarchy;
import matlab.unittest.fixtures.EmptyFixture;

classes = getAllTestCaseClassesInHierarchy(testClass);
sharedTestFixtures = [classes.SharedTestFixtures];
sharedTestFixtures = [EmptyFixture.empty, sharedTestFixtures{:}];
sharedTestFixtures = getUniqueTestFixtures(sharedTestFixtures);

% Make a copy to keep from modifying the fixture handles stored on the metaclass.
fixtures = copy(sharedTestFixtures);
end


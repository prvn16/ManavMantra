function allClasses = getAllTestCaseClassesInHierarchy(metacls)
% The function is undocumented and may change in a future release.

% Perform a breadth-first search of a class's superclasses. Return an array
% containing all the superclasses such that, for any two classes in the
% array, the one listed first in the array is either a superclass of the
% second class, or there is no inheritance relationship.

% Copyright 2013-2014 The MathWorks, Inc.

validateattributes(metacls,{'matlab.unittest.meta.class'}, {'scalar'}, '', 'metacls');

allClasses = metacls;
toExamine = metacls;

while ~isempty(toExamine)
    for superclass = rot90(toExamine(1).SuperclassList, 3)
        if metaclass(superclass) <= ?matlab.unittest.meta.class
            allClasses(allClasses == superclass) = [];
            allClasses = [superclass, allClasses]; %#ok<AGROW>
            toExamine = [toExamine, superclass]; %#ok<AGROW>
        end
    end
    toExamine(1) = [];
end
end

% LocalWords:  metacls

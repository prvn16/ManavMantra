function tf = isConcreteSubclassOf(className, superclassName)
%ISCONCRETESUBCLASSOF Checks if the 1st input is a concrete subclass of 2nd.
%   Both className and superclassName inputs must be strings.
%   1. Checks if the given className, is not an abstract class.
%   2. Checks if the given className is a subclass of superClassName.

%   Copyright 2015 The MathWorks, Inc.

    tf = false;
    % If both strings are same, return false
    if strcmp(superclassName, className)
        return;
    end
    givenclass = meta.class.fromName(className);
    % meta.class.fromName returns an 0x0 array
    % if a random string is given.
    if isempty(givenclass) || givenclass.Abstract
        return;
    end
    superclassList = givenclass.SuperclassList;
    while ~isempty(superclassList)
        sClassNames = {superclassList.Name};
        % Check if one of the superclasses in the list
        % is the given super class name.
        if any(strcmp(sClassNames, superclassName))
            tf = true;
            return;
        end
        % next set of super class lists.
        superclassList = vertcat(superclassList.SuperclassList);
    end
end

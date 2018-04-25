function validateMethodAttributes(methodsToCheck, instance, ignoredAttributes)
% This function is undocumented and may change in a future release.

% Validate that INSTANCE's implementation of METHODSTOCHECK respects all method
% attribute values, except for attributes specified by IGNOREDATTRIBUTES.

% Copyright 2017 The MathWorks, Inc.

methodsToCheck = reshape(methodsToCheck, 1, []);

allMethodAttributes = properties(methodsToCheck);
attributesToCheck = reshape(setdiff(allMethodAttributes, ignoredAttributes), 1, []);

instanceMetaclass = builtin('metaclass', instance);
instanceMethods = instanceMetaclass.MethodList;

for attribute = attributesToCheck
    for method = methodsToCheck
        correspondingInstanceMethod = instanceMethods.findobj('Name', method.Name);
        if ~isempty(correspondingInstanceMethod) && ...
                ~isequal(method.(attribute), correspondingInstanceMethod.(attribute))
            error(message('MATLAB:mock:MockContext:NonDefaultMethodAttributeValue', ...
                method.Name, attribute));
        end
    end
end
end

% LocalWords:  INSTANCE's IGNOREDATTRIBUTES METHODSTOCHECK

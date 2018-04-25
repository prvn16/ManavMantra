function validatePropertyAttributes(propertiesToCheck, instance, ignoredAttributes)
% This function is undocumented and may change in a future release.

% Validate that INSTANCE's implementation of PROPERTIESTOCHECK respects all method
% attribute values, except for attributes specified by IGNOREDATTRIBUTES.

% Copyright 2017 The MathWorks, Inc.

propertiesToCheck = reshape(propertiesToCheck, 1, []);

allPropertyAttributes = properties(propertiesToCheck);
attributesToCheck = reshape(setdiff(allPropertyAttributes, ignoredAttributes), 1, []);

instanceMetaclass = builtin('metaclass', instance);
instanceProperties = instanceMetaclass.PropertyList;

for attribute = attributesToCheck
    for property = propertiesToCheck
        correspondingInstanceProperty = instanceProperties.findobj('Name', property.Name);
        if ~isempty(correspondingInstanceProperty) && ...
                ~isequal(property.(attribute), correspondingInstanceProperty.(attribute))
            error(message('MATLAB:mock:MockContext:NonDefaultPropertyAttributeValue', ...
                property.Name, attribute));
        end
    end
end
end

% LocalWords:  INSTANCE's PROPERTIESTOCHECK IGNOREDATTRIBUTES

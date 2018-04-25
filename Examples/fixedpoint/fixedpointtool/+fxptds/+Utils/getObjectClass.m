function objClass = getObjectClass(result)
%% GETOBJECTCLASS function returns the object class of the block object associated with the result

%   Copyright 2016-2017 The MathWorks, Inc.

    % Geck 1443596 created to move this function to Result Object
    object = result.UniqueIdentifier.getObject;
    if fxptds.isSFMaskedSubsystem(object)
        object = fxptds.getSFChartObject(object);
    end
    objClass = {class(object)};
end
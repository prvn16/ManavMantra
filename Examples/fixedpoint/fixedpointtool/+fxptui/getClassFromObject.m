function objClass = getClassFromObject(object)
% GETCLASSFROMOBJECT Helper function to get the object's class

% Copyright 2016 The MathWorks, Inc.

if fxptds.isSFMaskedSubsystem(object)
    object = fxptds.getSFChartObject(object);
end
objClass = class(object);
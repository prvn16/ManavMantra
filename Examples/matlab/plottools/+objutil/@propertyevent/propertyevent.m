classdef propertyevent < matlab.mixin.SetGet & matlab.mixin.Copyable
       
    properties (SetObservable, GetObservable)
        Type char = '';
        Source;
        AffectedObject;
        NewValue;
    end
end
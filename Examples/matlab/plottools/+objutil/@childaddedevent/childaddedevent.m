classdef childaddedevent < matlab.mixin.SetGet & matlab.mixin.Copyable
    properties (SetObservable, GetObservable)
        Type char = '';
        Source;
        Child;
    end
end
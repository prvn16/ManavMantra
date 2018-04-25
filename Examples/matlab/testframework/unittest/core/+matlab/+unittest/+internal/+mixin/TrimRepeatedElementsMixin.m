classdef (HandleCompatible) TrimRepeatedElementsMixin
    % TrimRepeatedElementsMixin - This class is undocumented. It can be
    % mixed in to trim contiguous repeated elements based on the eq method.
    % repeats are those where the next is the same as the previous. By
    % convention the first is never a repeat
    
    %  Copyright 2015 The MathWorks, Inc.
    methods(Abstract)
        tf = eq(obj1, obj2);
    end
    
    methods
        function obj = trimRepeatedElements(obj)
            
            first = false;
            repeats = [first obj(1:end-1) == obj(2:end)];
            obj(repeats) = [];
            
        end
    end
end
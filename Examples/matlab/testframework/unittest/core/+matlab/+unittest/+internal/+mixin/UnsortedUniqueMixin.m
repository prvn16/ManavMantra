classdef (HandleCompatible) UnsortedUniqueMixin
    % UnsortedUniqueMixin - This class is undocumented. This class can be
    % mixed in to find an unsorted unique list based on the eq method.
    
    %  Copyright 2015 The MathWorks, Inc.
    methods(Abstract)
        tf = eq(obj1, obj2);
    end
    
    methods
        function uniqueObjects = unsortedUnique(obj)
            uniqueObjects = obj.empty(1, 0);
            while ~isempty(obj)
                uniqueObjects(end+1) = obj(1); %#ok<AGROW>
                indices = obj == obj(1);
                obj(indices) = [];
            end
        end
    end
end
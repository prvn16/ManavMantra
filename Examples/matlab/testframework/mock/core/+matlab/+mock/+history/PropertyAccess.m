classdef PropertyAccess < matlab.mock.InteractionHistory
    % PropertyAccess - Representation of a mock object property access.
    %
    %   A PropertyAccess instance represents the access of a mock object
    %   property value. The framework constructs instances of the class, so
    %   there is no need to construct this class directly.
    %
    %   PropertyAccess properties:
    %       Name  - Name of property.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden)
        function history = PropertyAccess(className, name)
            history = history@matlab.mock.InteractionHistory(className, name);
        end
        
        function bool = describedBy(history, behavior)
            bool = behavior.describesPropertyAccess(history);
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function summary = getElementDisplaySummary(historyElement)
            import matlab.mock.internal.propertyDisplay;
            summary = propertyDisplay(historyElement.Name, historyElement.ClassName);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name'};
        end
    end
end


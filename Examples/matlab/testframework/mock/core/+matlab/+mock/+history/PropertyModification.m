classdef PropertyModification < matlab.mock.InteractionHistory
    % PropertyModification - Representation of a mock object property modification.
    %
    %   A PropertyModification instance represents the modification of a mock
    %   object property value. The framework constructs instances of the class,
    %   so there is no need to construct this class directly.
    %
    %   PropertyModification properties:
    %       Name  - Name of property.
    %       Value - Value assigned to property.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Value - Value assigned to property.
        %
        %   The Value property indicates the property value in the mock object
        %   property modification.
        Value;
    end
    
    methods (Hidden, Sealed)
        function history = PropertyModification(className, name, value)
            history = history@matlab.mock.InteractionHistory(className, name);
            history.Value = value;
        end
        
        function bool = describedBy(history, behavior)
            bool = behavior.describesPropertyModification(history);
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function summary = getElementDisplaySummary(historyElement)
            import matlab.mock.internal.propertyDisplay;
            summary = propertyDisplay(historyElement.Name, historyElement.ClassName, historyElement.Value);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Value'};
        end
    end
end


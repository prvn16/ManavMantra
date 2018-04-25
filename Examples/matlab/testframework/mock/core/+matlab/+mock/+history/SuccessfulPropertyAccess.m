classdef SuccessfulPropertyAccess < matlab.mock.history.PropertyAccess
    % SuccessfulPropertyAccess - Representation of a successful mock object property access.
    %
    %   A SuccessfulPropertyAccess instance represents the successful access of
    %   a mock object property value. The framework constructs instances of the
    %   class, so there is no need to construct this class directly.
    %
    %   SuccessfulPropertyAccess properties:
    %       Name  - Name of property.
    %       Value - Property value accessed.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Value - Property value accessed.
        %
        %   The Value property represents the value returned when the mock object
        %   property was accessed.
        Value;
    end
    
    methods (Hidden)
        function history = SuccessfulPropertyAccess(className, name, value)
            history = history@matlab.mock.history.PropertyAccess(className, name);
            history.Value = value;
        end
        
        function bool = describedBy(history, behavior)
            bool = behavior.describesSuccessfulPropertyAccess(history);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Value'};
        end
    end
end


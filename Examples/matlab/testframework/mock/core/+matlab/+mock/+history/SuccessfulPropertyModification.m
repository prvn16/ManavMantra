classdef (Sealed) SuccessfulPropertyModification < matlab.mock.history.PropertyModification
    % SuccessfulPropertyModification - Representation of a successful mock object property modification.
    %
    %   A SuccessfulPropertyModification instance represents the successful
    %   modification of a mock object property value. The framework constructs
    %   instances of the class, so there is no need to construct this class
    %   directly.
    %
    %   SuccessfulPropertyModification properties:
    %       Name  - Name of property.
    %       Value - Value assigned to property.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden)
        function history = SuccessfulPropertyModification(className, name, value)
            history = history@matlab.mock.history.PropertyModification(className, name, value);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Value'};
        end
    end
end


classdef (Sealed) UnsuccessfulPropertyModification < matlab.mock.history.PropertyModification & ...
        matlab.mock.internal.history.UnsuccessfulInteractionMixin
    % UnsuccessfulPropertyModification - Representation of an unsuccessful mock object property modification.
    %
    %   An UnsuccessfulPropertyModification instance represents a mock object
    %   property modification that threw an exception. The framework constructs
    %   instances of the class, so there is no need to construct this class
    %   directly.
    %
    %   UnsuccessfulPropertyModification properties:
    %       Name      - Name of property.
    %       Value     - Value of attempted property assignment.
    %       Exception - Exception produced by mock object property modification.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden)
        function history = UnsuccessfulPropertyModification(className, name, value, exception)
            history = history@matlab.mock.history.PropertyModification(className, name, value);
            history = history@matlab.mock.internal.history.UnsuccessfulInteractionMixin(exception);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Value', 'Exception'};
        end
    end
end


classdef (Sealed) UnsuccessfulPropertyAccess < matlab.mock.history.PropertyAccess & ...
        matlab.mock.internal.history.UnsuccessfulInteractionMixin
    % UnsuccessfulPropertyAccess - Representation of an unsuccessful mock object property access.
    %
    %   An UnsuccessfulPropertyAccess instance represents a mock object property access that threw an exception. The framework constructs instances of the
    %   class, so there is no need to construct this class directly.
    %
    %   UnsuccessfulPropertyAccess properties:
    %       Name      - Name of property.
    %       Exception - Exception produced by mock object property access.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden)
        function history = UnsuccessfulPropertyAccess(className, name, exception)
            history = history@matlab.mock.history.PropertyAccess(className, name);
            history = history@matlab.mock.internal.history.UnsuccessfulInteractionMixin(exception);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Exception'};
        end
    end
end


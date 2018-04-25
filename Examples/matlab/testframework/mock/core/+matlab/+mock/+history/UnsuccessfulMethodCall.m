classdef (Sealed) UnsuccessfulMethodCall < matlab.mock.history.MethodCall & ...
        matlab.mock.internal.history.UnsuccessfulInteractionMixin
    % UnsuccessfulMethodCall - Representation of an unsuccessful mock object method call.
    %   A UnsuccessfulMethodCall instance represents a call to a mock object
    %   method that threw an exception. The framework constructs instances of
    %   the class, so there is no need to construct this class directly.
    %
    %   UnsuccessfulMethodCall properties:
    %       Name      - Method name.
    %       Inputs    - Inputs passed to the method.
    %       Exception - Exception produced by mock object method call.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden)
        function history = UnsuccessfulMethodCall(className, name, static, inputs, numOutputs, exception)
            history = history@matlab.mock.history.MethodCall(className, name, static, inputs, numOutputs);
            history = history@matlab.mock.internal.history.UnsuccessfulInteractionMixin(exception);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Inputs', 'Exception'};
        end
    end
end


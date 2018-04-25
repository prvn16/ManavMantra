classdef (Sealed) SuccessfulMethodCall < matlab.mock.history.MethodCall
    % SuccessfulMethodCall - Representation of a successful mock object method call.
    %   A SuccessfulMethodCall instance represents a call to a mock object
    %   method that ran to completion. The framework constructs instances of
    %   the class, so there is no need to construct this class directly.
    %
    %   SuccessfulMethodCall properties:
    %       Name    - Method name.
    %       Inputs  - Inputs passed to method.
    %       Outputs - Outputs returned from method call.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Outputs - Outputs returned from method call.
        %
        %   The Outputs property is a cell vector indicating the outputs returned
        %   from the method call.
        Outputs (1,:) cell;
    end
    
    methods (Hidden)
        function history = SuccessfulMethodCall(className, name, static, inputs, numOutputs, outputs)
            history = history@matlab.mock.history.MethodCall(className, name, static, inputs, numOutputs);
            history.Outputs = outputs;
        end
        
        function bool = describedBy(history, behavior)
            bool = behavior.describesSuccessfulMethodCall(history);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Inputs', 'Outputs'};
        end
    end
end


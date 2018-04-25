classdef MethodCall < matlab.mock.InteractionHistory
    % MethodCall - Representation of a mock object method call.
    %   A MethodCall instance represents a call to a mock object method. The
    %   framework constructs instances of the class, so there is no need to
    %   construct this class directly.
    %
    %   MethodCall properties:
    %       Name   - Method name.
    %       Inputs - Inputs passed to method.
    %
    %   See also:
    %       matlab.mock.history
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable, GetAccess=private)
        Static (1,1) logical;
    end
    
    properties (SetAccess=immutable)
        % Inputs - Inputs passed to mock object method.
        %
        %   The Inputs property is a cell vector indicating the inputs passed to
        %   the mock object method.
        Inputs (1,:) cell;
    end
    
    properties (Hidden, SetAccess=immutable)
        NumOutputs (1,1) double;
    end
    
    methods (Hidden)
        function history = MethodCall(className, name, static, inputs, numOutputs)
            history = history@matlab.mock.InteractionHistory(className, name);
            history.Static = static;
            history.Inputs = inputs;
            history.NumOutputs = numOutputs;
        end
        
        function bool = describedBy(history, behavior)
            bool = behavior.describesMethodCall(history);
        end
    end
    
    methods (Hidden, Sealed, Access=protected)
        function summary = getElementDisplaySummary(historyElement)
            import matlab.mock.internal.methodCallDisplay;
            summary = methodCallDisplay(historyElement.ClassName, historyElement.Name, ...
                historyElement.Static, historyElement.Inputs);
        end
    end
    
    methods (Hidden, Static, Access=protected)
        function list = getPropertyList(~)
            list = {'Name', 'Inputs'};
        end
    end
end


classdef AssignOutputs < matlab.mock.actions.MethodCallAction & ...
        matlab.mock.actions.PropertyGetAction
    % AssignOutputs - Return predefined outputs.
    %
    %   The AssignOutputs action specifies values that are returned when a mock
    %   object method is invoked or a mock object property is accessed. The
    %   AssignOutputs constructor accepts one or more values that correspond to
    %   the values provided for the output arguments of the mock object method
    %   or the value provided for the property. AssignOutputs can be used to
    %   implement the stub pattern by specifying predetermined values to be
    %   returned.
    %
    %   AssignOutputs methods:
    %       AssignOutputs - Class constructor
    %       then          - Specify subsequent action
    %       repeat        - Perform the same action multiple times
    %
    %   AssignOutputs properties:
    %       Outputs - The values to be returned
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.actions.ThrowException
    %       matlab.mock.MethodCallBehavior/when
    %       matlab.mock.PropertyGetBehavior/when
    %
    
    % Copyright 2015-2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Outputs - The values to be returned
        %
        %   The Outputs property is a cell array of arguments to be returned from a
        %   mock object method call or property access.
        Outputs cell;
    end
    
    methods
        function action = AssignOutputs(varargin)
            % AssignOutputs - Class constructor.
            %
            %   action = AssignOutputs(output1, output2, output3, ...) constructs an
            %   AssignOutputs instance. The specified values are returned when the
            %   action is used to carry out the implementation of a mock object method.
            %
            %   Example:
            %       import matlab.mock.actions.AssignOutputs;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a quadrilateral class
            %       [mock, behavior] = testCase.createMock("AddedMethods","sideLengths");
            %
            %       % Set up behavior
            %       when(withAnyInputs(behavior.sideLengths), AssignOutputs(2,2,4,4));
            %
            %       % Use the mock
            %       [a,b,c,d] = mock.sideLengths
            %
            
            narginchk(1, Inf);
            action.Outputs = varargin;
        end
    end
    
    methods (Hidden)
        function varargout = callMethod(action, varargin)
            varargout = action.Outputs;
        end
        
        function value = getProperty(action, varargin)
            value = action.Outputs{:};
        end
    end
end

% LocalWords:  narginchk

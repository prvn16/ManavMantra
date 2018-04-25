classdef ThrowException < matlab.mock.actions.MethodCallAction & ...
        matlab.mock.actions.PropertyGetAction & ...
        matlab.mock.actions.PropertySetAction
    % ThrowException - Throw an exception.
    %
    %   The ThrowException action throws an exception when a mock object method
    %   is invoked or a property is set or accessed. It can be used to
    %   implement the saboteur pattern by injecting error conditions into the
    %   system being tested.
    %
    %   ThrowException methods:
    %       ThrowException - Class constructor
    %       then           - Specify subsequent action
    %       repeat         - Perform the same action multiple times
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.actions.AssignOutputs
    %       matlab.mock.MethodCallBehavior/when
    %       matlab.mock.PropertyGetBehavior/when
    %       matlab.mock.PropertySetBehavior/when
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable, GetAccess=private)
        % Exception - Exception to be thrown
        %
        %   The Exception property holds the MException instance that is thrown
        %   when a mock object is used.
        %
        Exception MException;
    end
    
    methods
        function action = ThrowException(exception)
            % ThrowException - Class constructor.
            %
            %   action = ThrowException(exception) constructs a ThrowException
            %   instance. The specified exception is thrown when the action is used to
            %   carry out the implementation of a mock object method.
            %
            %   action = ThrowException constructs a ThrowException instance that
            %   throws a generic exception.
            %
            %   Examples:
            %       import matlab.mock.actions.ThrowException;
            %       import matlab.unittest.constraints.IsLessThan;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a bank account class
            %       [mock, behavior] = testCase.createMock("AddedMethods","deposit");
            %
            %       % Set up behavior
            %       when(behavior.deposit(IsLessThan(0)), ...
            %           ThrowException(MException('Account:deposit:Negative', ...
            %           'Deposit amount must be positive.')));
            %
            %       % Use the mock
            %       mock.deposit(10);
            %       mock.deposit(-10);
            %
            
            if nargin > 0
                validateattributes(exception, {'MException'}, {'scalar'});
                action.Exception = exception;
            end
        end
    end
    
    methods (Hidden)
        function varargout = callMethod(action, className, methodName, static, varargin) %#ok<STOUT>
            import matlab.mock.internal.methodCallDisplay;
            
            exception = action.Exception;
            if isempty(exception)
                exception = MException(message('MATLAB:mock:ThrowException:DefaultMethodCallException', ...
                    methodCallDisplay(className, methodName, static, varargin)));
            end
            
            throwAsCaller(exception);
        end
        
        function value = getProperty(action, className, propertyName, ~) %#ok<STOUT>
            import matlab.mock.internal.propertyDisplay;
            
            exception = action.Exception;
            if isempty(exception)
                exception = MException(message('MATLAB:mock:ThrowException:DefaultPropertyAccessException', ...
                    propertyDisplay(propertyName, className)));
            end
            
            throwAsCaller(exception);
        end
        
        function setProperty(action, className, propertyName, ~, value)
            import matlab.mock.internal.propertyDisplay;
            
            exception = action.Exception;
            if isempty(exception)
                exception = MException(message('MATLAB:mock:ThrowException:DefaultPropertySetException', ...
                    propertyDisplay(propertyName, className, value)));
            end
            
            throwAsCaller(exception);
        end
    end
end

% LocalWords:  unittest

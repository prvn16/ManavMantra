classdef ReturnStoredValue < matlab.mock.actions.PropertyGetAction
    % ReturnStoredValue - Return the stored value of a property.
    %
    %   The ReturnStoredValue action specifies that the stored value should be
    %   returned when accessing a property.
    %
    %   ReturnStoredValue methods:
    %       ReturnStoredValue - Class constructor
    %       then              - Specify subsequent action
    %       repeat            - Perform the same action multiple times
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.actions.AssignOutputs
    %       matlab.mock.actions.StoreValue
    %       matlab.mock.actions.ThrowException
    %       matlab.mock.PropertyGetBehavior/when
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function action = ReturnStoredValue
            % ReturnStoredValue - Class constructor
            %
            %   action = ReturnStoredValue constructs a ReturnStoredValue instance.
            %
            %   Example:
            %       import matlab.mock.actions.ReturnStoredValue;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create strict mock; all property interactions throw exceptions by default
            %       properties = ["PropA", "PropB", "PropC"];
            %       [mock, behavior] = testCase.createMock("AddedProperties",properties, "Strict",true);
            %
            %       % Enable PropA only to be accessed instead of throwing an exception
            %       when(get(behavior.PropA), ReturnStoredValue);
            %
            %       % Use the mock
            %       mock.PropA
            %       mock.PropB
            %
        end
    end
    
    methods (Hidden)
        function value = getProperty(~, ~, propertyName, object)
            value = builtin('matlab.mock.internal.getProperty', ...
                propertyName, object);
        end
    end
end


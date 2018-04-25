classdef StoreValue < matlab.mock.actions.PropertySetAction
    % StoreValue - Store a property value.
    %
    %   The StoreValue action specifies that the specified value should be
    %   stored when setting a property.
    %
    %   StoreValue methods:
    %       StoreValue - Class constructor
    %       then       - Specify subsequent action
    %       repeat     - Perform the same action multiple times
    %
    %   See also:
    %       matlab.mock.TestCase
    %       matlab.mock.actions.ReturnStoredValue
    %       matlab.mock.actions.ThrowException
    %       matlab.mock.PropertySetBehavior/when
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function action = StoreValue
            % StoreValue - Class constructor
            %
            %   action = StoreValue constructs a StoreValue instance.
            %
            %   Example:
            %       import matlab.mock.actions.StoreValue;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create strict mock; all property interactions throw exceptions by default
            %       properties = ["PropA", "PropB", "PropC"];
            %       [mock, behavior] = testCase.createMock("AddedProperties",properties, "Strict",true);
            %
            %       % Enable PropA only to be accessed instead of throwing an exception
            %       when(set(behavior.PropA), StoreValue);
            %
            %       % Use the mock
            %       mock.PropA = 1;
            %       mock.PropB = 2;
            %
        end
    end
    
    methods (Hidden)
        function setProperty(~, ~, propertyName, object, value)
            builtin('matlab.mock.internal.setProperty', ...
                propertyName, object, value);
        end
    end
end


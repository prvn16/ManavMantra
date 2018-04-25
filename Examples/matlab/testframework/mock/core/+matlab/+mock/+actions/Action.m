classdef (Hidden, Abstract) Action < matlab.mixin.internal.Scalar
    % This class is undocumented and may change in a future release.
    
    % Action - Fundamental interface for mock object behavior.
    %
    %   The Action interface provides a means for specifying behaviors mock
    %   objects should perform in response to interactions.
    %
    %   Action methods:
    %       then    - Specify subsequent action
    %       repeat  - Perform the same action multiple times
    %
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties (Hidden, Dependent, SetAccess=private)
        NextAction;
    end
    
    properties (Access=private)
        NextList = {};
    end
    
    methods (Sealed)
        function action = then(action, next)
            % then - Specify subsequent action
            %
            %   The then method is used to specify an action that should be
            %   performed for subsequent mock object interactions.
            %
            %   Examples:
            %     Specify behavior for a method:
            %
            %       import matlab.mock.actions.AssignOutputs;
            %       import matlab.mock.actions.ThrowException;
            %
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a bank account class
            %       [mock, behavior] = testCase.createMock("AddedMethods","isOpen");
            %
            %       % Set up behavior
            %       when(withExactInputs(behavior.isOpen), then(AssignOutputs(true), ...
            %           then(AssignOutputs(true), then(AssignOutputs(false), ...
            %           then(ThrowException)))));
            %
            %       % Use the mock:
            %       % isOpen calls return true, true, false, then throws an exception
            %       isAccountOpen = mock.isOpen
            %       isAccountOpen = mock.isOpen
            %       isAccountOpen = mock.isOpen
            %       isAccountOpen = mock.isOpen
            %
            %
            %     Specify behavior for a property:
            %
            %       import matlab.mock.actions.AssignOutputs;
            %       import matlab.mock.actions.ReturnStoredValue;
            %       import matlab.mock.actions.ThrowException;
            %
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       
            %       [mock, behavior] = testCase.createMock("AddedProperties","Prop");
            %
            %       when(get(behavior.Prop), then(AssignOutputs(1), ...
            %           then(ReturnStoredValue, then(AssignOutputs(3), ...
            %           then(ThrowException)))));
            %
            %       mock.Prop = 5;
            %       for i = 1:4
            %           mock.Prop
            %       end
            %
            
            validateattributes(action, {'matlab.mock.actions.Action'}, {});
            if nargin > 1
                validateattributes(next, {'matlab.mock.actions.Action'}, {});
                action.NextAction = next;
            end
        end
        
        function repeated = repeat(numTimes, action)
            % repeat - Perform the same action multiple times
            %
            %   The repeat method is used to specify that an action should be performed
            %   more than once for subsequent mock object interactions.
            %
            %   Examples:
            %
            %     Specify behavior for a method:
            %
            %       import matlab.mock.actions.AssignOutputs;
            %       import matlab.mock.actions.ThrowException;
            %
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a bank account class
            %       [mock, behavior] = testCase.createMock("AddedMethods","isOpen");
            %
            %       % Specify behavior
            %       when(withExactInputs(behavior.isOpen), then(repeat(5, AssignOutputs(true)), ...
            %           then(AssignOutputs(false), then(ThrowException))));
            %
            %       % Use the mock
            %       for i = 1:7
            %       	isAccountOpen = mock.isOpen
            %       end
            %
            %
            %     Specify behavior for a property:
            %
            %       import matlab.mock.actions.AssignOutputs;
            %       import matlab.mock.actions.ReturnStoredValue;
            %       import matlab.mock.actions.ThrowException;
            %
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %       
            %       [mock, behavior] = testCase.createMock("AddedProperties","Prop");
            %
            %       when(get(behavior.Prop), then(repeat(3,AssignOutputs(1)), ...
            %           then(repeat(2,ReturnStoredValue), then(AssignOutputs(3), ...
            %           then(ThrowException)))));
            %
            %       mock.Prop = 5;
            %       for i = 1:7
            %           mock.Prop
            %       end
            
            validateattributes(numTimes, {'numeric'}, {'positive', 'integer', 'scalar'});
            
            if ~isempty(action.NextList)
               error(message("MATLAB:mock:Action:NotRepeatable", "repeat", "then"));
            end
            
            repeated = action;
            for idx = 2:numTimes
                repeated = repeated.then(action);
            end
        end
    end
    
    methods (Hidden, Sealed)
        function applyToAllActionsInList(action, fcn)
            for a = [{action}, action.NextList]
                fcn(a{:});
            end
        end
    end
    
    methods
        function next = get.NextAction(action)
            if isempty(action.NextList)
                next = action;
                return;
            end
            
            next = action.NextList{1};
            next.NextList = action.NextList(2:end);
        end
        
        function action = set.NextAction(action, next)
            nextList = next.NextList;
            next.NextList = {};
            action.NextList = [action.NextList, {next}, nextList];
        end
    end
end


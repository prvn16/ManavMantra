classdef (Sealed) PropertyGetBehavior < matlab.mixin.internal.Scalar & matlab.mixin.CustomDisplay
    % PropertyGetBehavior - Specification of property access behavior.
    %
    %   Use the PropertyGetBehavior to specify behavior for mock object
    %   property access. Obtain a PropertyGetBehavior instance by calling
    %   the get method on the output returned by accessing a property of the
    %   Behavior.
    %
    %   The framework creates instances of this class, so there is no need for
    %   test authors to construct instances of the class directly.
    %
    %   PropertyGetBehavior methods:
    %       when - Specify mock object property access action
    %
    %   See also:
    %       matlab.mock.PropertyBehavior
    %       matlab.mock.constraints.WasAccessed
    %
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable)
        % Name - String indicating the property name
        %
        %   The Name property is a string that indicates the name of the property.
        %
        Name string;
    end
    
    properties (Hidden, SetAccess=private)
        % Value - Value of the property
        %
        %   The Value property is the value the mock object property returned when
        %   accessed.
        %
        Value;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        ValueRequirement matlab.mock.internal.Requirement;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        % Count - Number of times the property was accessed
        %
        %   The Count property is a scalar double that indicates the number of
        %   times the mock object property was accessed.
        %
        Count double;
    end
    
    properties (Hidden, SetAccess=private)
        HasValue logical = false;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        InteractionCatalog matlab.mock.internal.InteractionCatalog;
    end
    
    properties (Hidden)
        Action;
    end
    
    methods (Hidden)
        function behavior = PropertyGetBehavior(catalog, name)
            behavior.InteractionCatalog = catalog;
            behavior.Name = name;
        end
        
        function behavior = withReturnValue(value, behavior)
            if builtin('metaclass',value) == ?matlab.mock.PropertyGetBehavior
                [value, behavior] = deal(behavior, value);
            end
            
            behavior.Value = value;
            behavior.HasValue = true;
        end
        
        function bool = describesPropertyAccess(behavior, history)
            bool = behavior.hasSameNameAs(history) && ~behavior.HasValue;
        end
        
        function bool = describesSuccessfulPropertyAccess(behavior, history)
            bool = behavior.hasSameNameAs(history) && behavior.valueRequirementSatisfiedBy(history);
        end
    end
    
    methods
        function when(behavior, action)
            % when - Specify mock object property access action
            %
            %   when(behavior, action) is used to specify the action that the mock
            %   object property should perform when accessed.
            %
            %   Example:
            %       import matlab.mock.actions.AssignOutputs;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a person class
            %       [mock, behavior] = testCase.createMock("AddedProperties","Name");
            %
            %       % Set up behavior
            %       when(get(behavior.Name), AssignOutputs("David"));
            %
            %       % Use the mock
            %       mock.Name
            
            if behavior.HasValue
                error(message('MATLAB:mock:PropertyGetBehavior:MustNotHaveValue'));
            end
            
            behavior.Action = action;
            behavior.InteractionCatalog.addPropertyGetSpecification(behavior);
        end
        
        function behavior = set.Action(behavior, action)
            validateattributes(action, {'matlab.mock.actions.PropertyGetAction'}, {});
            action.applyToAllActionsInList(@(a)validateattributes(a, ...
                {'matlab.mock.actions.PropertyGetAction'}, {}));
            behavior.Action = action;
        end
        
        function count = get.Count(behavior)
            count = behavior.InteractionCatalog.getPropertyGetCount(behavior);
        end
        
        function value = get.Value(behavior)
            if ~behavior.HasValue
                error(message('MATLAB:mock:PropertyGetBehavior:NoValue'));
            end
            value = behavior.Value;
        end
        
        function requirement = get.ValueRequirement(behavior)
            import matlab.mock.internal.values2requirements;
            requirement = values2requirements({behavior.Value});
        end
    end
    
    methods (Access=private)
        function bool = hasSameNameAs(behavior, otherBehavior)
            bool = behavior.Name == otherBehavior.Name;
        end
        
        function bool = valueRequirementSatisfiedBy(behavior, history)
            bool = ~behavior.HasValue || ...
                behavior.ValueRequirement.satisfiedByAllArguments({history.Value});
        end
    end
    
    methods (Hidden, Access=protected)
        function header = getHeader(behavior)
            header = behavior.getClassNameForHeader(behavior);
        end
        
        function footer = getFooter(behavior)
            % Note: this method assumes the object is always scalar.
            
            import matlab.unittest.internal.diagnostics.indent;
            
            footer = indent([getString(message('MATLAB:mock:display:MockObjectSummary', ...
                char(behavior.InteractionCatalog.MockObjectSimpleClassName))), '.', char(behavior.Name)]);
            footer = [footer, newline];
        end
    end
end

% LocalWords:  unittest

classdef (Sealed) PropertySetBehavior < matlab.mixin.internal.Scalar & matlab.mixin.CustomDisplay
    % PropertySetBehavior - Specification of property set behavior.
    %
    %   Use the PropertySetBehavior to specify behavior when a mock object
    %   property is set. Obtain a PropertySetBehavior instance by calling
    %   the set method on the output returned by accessing a property of the
    %   Behavior.
    %
    %   The framework creates instances of this class, so there is no need for
    %   test authors to construct instances of the class directly.
    %
    %   PropertySetBehavior methods:
    %       when - Specify mock object property set action
    %
    %   See also:
    %       matlab.mock.PropertyBehavior
    %       matlab.mock.constraints.WasSet
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
        % Value - Property value requirement
        %
        %   The Value property is any value specifying the criterion that the value
        %   the property was set to must satisfy. The default Value is
        %   matlab.unittest.constraints.IsAnything, meaning that the property can
        %   take on any value.
        %
        %   Set the Value property through the setToValue method of PropertyBehavior.
        %
        %   See also:
        %       matlab.mock.PropertyBehavior/setToValue
        %
        Value = matlab.unittest.constraints.IsAnything;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        ValueRequirement matlab.mock.internal.Requirement;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        % Count - Number of times the property was set
        %
        %   The Count property is a scalar double that indicates the number of
        %   times the mock object property was set.
        Count double;
        
        % SetsToAnyValue - List of all observed property sets
        %
        %   The SetsToAnyValue is a string array representing all observed sets
        %   of the property to any value.
        SetsToAnyValue string;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        InteractionCatalog matlab.mock.internal.InteractionCatalog;
    end
    
    properties (Hidden)
        Action;
    end
    
    methods (Hidden)
        function behavior = PropertySetBehavior(catalog, name, value)
            behavior.InteractionCatalog = catalog;
            behavior.Name = name;
            
            if nargin > 2
                behavior.Value = value;
            end
        end
        
        function bool = describesPropertyModification(behavior, history)
            bool = behavior.Name == history.Name && ...
                behavior.ValueRequirement.satisfiedByAllArguments({history.Value});
        end
    end
    
    methods
        function when(behavior, action)
            % when - Specify mock object property set action
            %
            %   when(behavior, action) is used to specify the action that the mock
            %   object property should perform when set.
            %
            %   Example:
            %       import matlab.mock.actions.ThrowException;
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a person class
            %       [mock, behavior] = testCase.createMock("AddedProperties","Name");
            %
            %       % Set up behavior
            %       when(set(behavior.Name), ThrowException(MException('Person:setName', ...
            %           'Unable to change the name')));
            %
            %       % Use the mock
            %       mock.Name = "New Name";
            %
            
            behavior.Action = action;
            behavior.InteractionCatalog.addPropertySetSpecification(behavior);
        end
        
        function behavior = set.Action(behavior, action)
            validateattributes(action, {'matlab.mock.actions.PropertySetAction'}, {});
            action.applyToAllActionsInList(@(a)validateattributes(a, ...
                {'matlab.mock.actions.PropertySetAction'}, {}));
            behavior.Action = action;
        end
        
        function requirement = get.ValueRequirement(behavior)
            import matlab.mock.internal.values2requirements;
            requirement = values2requirements({behavior.Value});
        end
        
        function count = get.Count(behavior)
            count = behavior.InteractionCatalog.getPropertySetCount(behavior);
        end
        
        function records = get.SetsToAnyValue(behavior)
            import matlab.mock.InteractionHistory;
            
            allSets = behavior.InteractionCatalog.getAllPropertySets(behavior.Name);
            history = [InteractionHistory.empty, allSets.Value];
            records = history.getDisplaySummary;
        end
    end
    
    methods (Hidden, Access=protected)
        function header = getHeader(behavior)
            header = behavior.getClassNameForHeader(behavior);
        end
        
        function footer = getFooter(behavior)
            import matlab.unittest.internal.diagnostics.indent;
            footer = [indent(behavior.getSpecificationDisplay), newline];
        end
    end
    
    methods (Access=private)
        function str = getSpecificationDisplay(behavior)
            % Note: this method assumes the object is always scalar.
            str = string + getString(message('MATLAB:mock:display:MockObjectSummary', ...
                behavior.InteractionCatalog.MockObjectSimpleClassName)) + "." + behavior.Name + ...
                " = " + behavior.ValueRequirement.OneLineSummary;
        end
    end
end

% LocalWords:  unittest

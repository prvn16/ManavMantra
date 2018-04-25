classdef (Sealed) PropertyBehavior < matlab.mixin.internal.Scalar & matlab.mixin.CustomDisplay
    % PropertyBehavior - Specification of property behavior and record of property interactions.
    %
    %   Use the PropertyBehavior to specify behavior for mock object properties
    %   and provide a record of property interactions. Obtain a
    %   PropertyBehavior instance by accessing a property of the Behavior.
    %
    %   The framework creates instances of this class, so there is no need for
    %   test authors to construct instances of the class directly.
    %
    %   PropertyBehavior methods:
    %       get        - Specify mock object property access behavior
    %       set        - Specify mock object property set behavior
    %       setToValue - Specify behavior when a property is set to a specific value
    %
    %   See also:
    %       matlab.mock.PropertyGetBehavior
    %       matlab.mock.PropertySetBehavior
    %       matlab.mock.constraints.WasSet
    %       matlab.mock.constraints.WasAccessed
    %
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable)
        % Name - String indicating the property name
        %
        %   The Name property is a string that indicates the name of the property.
        %
        Name string;
    end
    
    properties (SetAccess=immutable, GetAccess=private)
        InteractionCatalog matlab.mock.internal.InteractionCatalog;
    end
    
    methods (Hidden)
        function behavior = PropertyBehavior(catalog, name)
            behavior.InteractionCatalog = catalog;
            behavior.Name = name;
        end
    end
    
    methods
        function getBehavior = get(behavior)
            % get - Specify mock object property access behavior
            %
            %   getBehavior = get(behavior) returns a PropertyGetBehavior. Use the
            %   PropertyGetBehavior to define mock object property access
            %   behavior.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a person class
            %       [mock, behavior] = testCase.createMock("AddedProperties","Name");
            %
            %       % Set up behavior
            %       testCase.assignOutputsWhen(get(behavior.Name), "David");
            %
            %       % Use the mock
            %       mock.Name
            %
            %   See also:
            %       matlab.mock.PropertyGetBehavior
            
            import matlab.mock.PropertyGetBehavior;
            getBehavior = PropertyGetBehavior(behavior.InteractionCatalog, behavior.Name);
        end
        
        function setBehavior = set(behavior)
            % set - Specify mock object property set behavior
            %
            %   setBehavior = set(behavior) returns a PropertySetBehavior. Use the
            %   PropertySetBehavior to define mock object property set behavior.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a person class
            %       [mock, behavior] = testCase.createMock("AddedProperties","Name");
            %
            %       % Set up behavior
            %       testCase.throwExceptionWhen(set(behavior.Name));
            %
            %       % Use the mock
            %       mock.Name = "Andy";
            %
            %   See also:
            %       matlab.mock.PropertySetBehavior
            
            import matlab.mock.PropertySetBehavior;
            setBehavior = PropertySetBehavior(behavior.InteractionCatalog, behavior.Name);
        end
        
        function setBehavior = setToValue(behavior, value)
            % setToValue - Specify behavior when a property is set to a specific value
            %
            %   setBehavior = behavior.setToValue(value) returns a PropertySetBehavior.
            %   Use the PropertySetBehavior to define mock object property set behavior.
            %
            %   Example:
            %       testCase = matlab.mock.TestCase.forInteractiveUse;
            %
            %       % Create a mock for a person class
            %       [mock, behavior] = testCase.createMock("AddedProperties","Name");
            %
            %       % Set up behavior
            %       testCase.throwExceptionWhen(behavior.Name.setToValue("David"));
            %
            %       % Use the mock
            %       mock.Name = "Andy";
            %       mock.Name = "David";
            %
            %   See also:
            %       matlab.mock.PropertySetBehavior
            
            import matlab.mock.PropertySetBehavior;
            
            label = builtin('matlab.mock.internal.getLabel', value);
            if isa(label, 'matlab.mock.internal.MockObjectRole')
                error(message('MATLAB:mock:PropertyBehavior:UnexpectedMockValue', 'Behavior'));
            end
            
            if builtin('metaclass',value) == ?matlab.mock.AnyArguments
                error(message('MATLAB:mock:PropertyBehavior:UnexpectedAnyArgumentsValue', 'AnyArguments', 'set'));
            end
            
            setBehavior = PropertySetBehavior(behavior.InteractionCatalog, behavior.Name, value);
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

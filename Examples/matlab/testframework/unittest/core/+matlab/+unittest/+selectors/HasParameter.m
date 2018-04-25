classdef (Sealed) HasParameter < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasParameter - Select TestSuite elements based on parameterization.
    %
    %   The HasParameter selector filters TestSuite array elements based on
    %   parameterization. The selector filters based on the name of the
    %   property that defines a parameter, the name of the parameter, and the
    %   value of the parameter. When multiple criteria are provided, the
    %   TestSuite array element must have at least one parameter which
    %   satisfies all the conditions in order to be retained.
    %
    %   HasParameter methods:
    %       HasParameter - Class constructor
    %
    %   HasParameter properties:
    %       PropertyConstraint - Condition that the parameter Property must satisfy.
    %       NameConstraint     - Condition that the parameter Name must satisfy.
    %       ValueConstraint    - Condition that the parameter Value must satisfy.
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasParameter;
    %       import matlab.unittest.constraints.IsGreaterThan;
    %       import matlab.unittest.constraints.StartsWithSubstring;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromPackage('mypackage');
    %
    %       % Select TestSuite array elements for all methods that are parameterized.
    %       newSuite = suite.selectIf(HasParameter);
    %
    %       % Select TestSuite array elements for all methods that are not parameterized.
    %       newSuite = suite.selectIf(~HasParameter);
    %
    %       % Select TestSuite array elements for all methods that are
    %       % parameterized by a parameter defined by a property named "Param"
    %       % with name "loop3".
    %       newSuite = suite.selectIf(HasParameter('Property','Param', 'Name','loop3'));
    %
    %       % Select TestSuite array elements for all methods using a
    %       % parameter defined by a property whose name starts with "Param".
    %       newSuite = suite.selectIf(HasParameter('Property',StartsWithSubstring('Param')));
    %
    %       % Select all TestSuite array elements for test methods that are
    %       % parameterized by a parameter defined by a property named "Size"
    %       % with value greater than 3.
    %       newSuite = suite.selectIf(HasParameter('Property','Size', 'Value',IsGreaterThan(3)));
    %
    %   See also: matlab.unittest.TestSuite/selectIf, matlab.unittest.parameters.Parameter
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % PropertyConstraint - Condition that the parameter Property must satisfy.
        %   The PropertyConstraint property is a
        %   matlab.unittest.constraints.Constraint instance which specifies the
        %   condition that the Property of a parameter must satisfy in order
        %   for the TestSuite array element to be retained.
        PropertyConstraint
        
        % NameConstraint - Condition that the parameter Name must satisfy.
        %   The NameConstraint property is a matlab.unittest.constraints.Constraint
        %   instance which specifies the condition that the Name of a parameter
        %   must satisfy in order for the TestSuite array element to be retained.
        NameConstraint
        
        % ValueConstraint - Condition that the parameter Name must satisfy.
        %   The ValueConstraint property is a matlab.unittest.constraints.Constraint
        %   instance which specifies the condition that the Value of a parameter
        %   must satisfy in order for the TestSuite array element to be retained.
        ValueConstraint
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.ParameterAttribute';
        AttributeAcceptMethodName char = 'acceptsParameter';
    end
    
    methods
        function selector = HasParameter(varargin)
            % HasParameter - Class constructor
            %
            %   selector = HasParameter(ATTRIBUTE,VALUE) creates a selector that filters
            %   TestSuite array elements based on parameterization. The constructor
            %   accepts any number of the following Name/Value pairs:
            %
            %       * Property - Name of the property that defines the parameter.
            %       * Name     - Name of the parameter.
            %       * Value    - Value of the parameter.
            %
            %   The Value for each Name/Value pair can be specified as a
            %   matlab.unittest.constraints.Constraint instance. A TestSuite array
            %   element is retained only if it contains at least one parameter that
            %   satisfies all the specified constraints. Additionally, 'Property'
            %   and 'Name' can be specified as a string or a character vector, and 'Value' 
            %   can be specified as any MATLAB datatype.
            
            import matlab.unittest.constraints.IsAnything;
            import matlab.unittest.internal.selectors.convertInputToConstraint;
            import matlab.unittest.internal.selectors.convertValueToConstraint;
            
            parser = matlab.unittest.internal.strictInputParser;
            
            parser.addParameter('Property',IsAnything);
            parser.addParameter('Name',IsAnything);
            parser.addParameter('Value',IsAnything);
            
            parser.parse(varargin{:});
            
            selector.PropertyConstraint = convertInputToConstraint(parser.Results.Property,'Property');
            selector.NameConstraint = convertInputToConstraint(parser.Results.Name,'Name');
            selector.ValueConstraint = convertValueToConstraint(parser.Results.Value);
        end
    end
end

% LocalWords:  mypackage

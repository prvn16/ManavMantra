classdef (Sealed) HasName < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasName - Select TestSuite elements by name.
    %
    %   The HasName selector filters TestSuite array elements based on the Name.
    %
    %   HasName methods:
    %       HasName - Class constructor
    %
    %   HasName properties:
    %       Constraint - Condition that the TestSuite Name must satisfy.
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasName;
    %       import matlab.unittest.constraints.StartsWithSubstring;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromPackage('mypackage');
    %
    %       % Select a single TestSuite element by name.
    %       newSuite = suite.selectIf(HasName('mypackage.TestClass1/TestMethod3'));
    %
    %       % Select all TestSuite elements whose name starts with "mypackage.subpack"
    %       newSuite = suite.selectIf(HasName(StartsWithSubstring('mypackage.subpack'));
    %
    %   See also: matlab.unittest.TestSuite/selectIf
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Constraint - Condition that the TestSuite Name must satisfy.
        %
        %   The Constraint property is a matlab.unittest.constraints.Constraint
        %   instance which specifies the condition that the Name of TestSuite array
        %   element must satisfy in order to be retained.
        Constraint
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.NameAttribute';
        AttributeAcceptMethodName char = 'acceptsName';
    end
    
    methods
        function selector = HasName(name)
            % HasName - Class constructor
            %
            %   selector = HasName(NAME) creates a selector that filters TestSuite
            %   array elements based on NAME. NAME can be either a string, character
            %   vector, or a matlab.unittest.constraints.Constraint instance. When NAME
            %   is a string or a character vector, only the TestSuite array elements
            %   whose Name exactly matches text specified by NAME are retained. When
            %   NAME is a constraint, the TestSuite array element's Name must satisfy
            %   the constraint in order to be retained.
            
            import matlab.unittest.internal.selectors.convertInputToConstraint;
            selector.Constraint = convertInputToConstraint(name,'Name');
        end
    end
end

% LocalWords:  mypackage subpack

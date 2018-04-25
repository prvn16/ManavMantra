classdef (Sealed) HasSuperclass < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasSuperclass - Select TestSuite elements by the test class hierarchy.
    %
    %   The HasSuperclass selector filters TestSuite array elements based
    %   on the class hierarchy of the TestClass.
    %
    %   HasSuperclass methods:
    %       HasSuperclass - Class constructor
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasSuperclass;
    %       import matlab.unittest.TestSuite;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromFolder(pwd);
    %
    %       % Select the TestSuite elements that have "BaseClass" in 
    %       % the class hierarchy.
    %       newSuite = suite.selectIf(HasSuperclass('BaseClass'));
    %
    %   See also: matlab.unittest.TestSuite/selectIf
    
    %   Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable, GetAccess = ?matlab.unittest.internal.selectors.SuperclassAttribute)
        Constraint
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.SuperclassAttribute';
        AttributeAcceptMethodName char = 'acceptsSuperclass';
    end
    
    methods
        function selector = HasSuperclass(class)
            % HasSuperClass - Class constructor
            %
            %   selector = HasSuperclass(CLASS) creates a selector that
            %   filters TestSuite array elements by retaining only those
            %   elements whose TestClass derives from CLASS. Specify CLASS
            %   as a character vector or string scalar.
            import matlab.unittest.constraints.IsSupersetOf;
            import matlab.unittest.internal.validateNonemptyText;
                      
            validateNonemptyText(class);
            selector.Constraint = IsSupersetOf(char(class));
        end
    end
end


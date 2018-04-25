classdef (Sealed) HasTag < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasTag - Select TestSuite elements by tag.
    %
    %   The HasTag selector filters TestSuite array elements based on a tag.
    %
    %   HasTag methods:
    %       HasTag - Class constructor
    %
    %   HasTag properties:
    %       Constraint - Condition that a TestSuite Tag must satisfy.
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasTag;
    %       import matlab.unittest.constraints.EndsWithSubstring;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromPackage('mypackage');
    %
    %       % Select a single TestSuite element by name.
    %       newSuite = suite.selectIf(HasTag('Nightly'));
    % 
    %       % Select all TestSuite elements whose tag end with "Performance"
    %       newSuite = suite.selectIf(HasTag(EndsWithSubstring('Performance'));
    %
    %   See also: matlab.unittest.TestSuite/selectIf
        
    
    %  Copyright 2014-2016 The MathWorks, Inc.
    
    
    properties (SetAccess = immutable)
        % Constraint - Condition that the TestSuite Tag must satisfy.
        %
        %   The Constraint property is a matlab.unittest.constraints.Constraint
        %   instance which specifies the condition that a Tag of TestSuite array
        %   element must satisfy in order to be retained.
        Constraint
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.TagAttribute';
        AttributeAcceptMethodName char = 'acceptsTag';
    end
    
    methods
        function selector = HasTag(tag)
            % HasTag - Class constructor
            %
            %   selector = HasName(TAG) creates a selector that filters TestSuite array
            %   elements by the test tag. TAG can be either a string, character vector,
            %   or a matlab.unittest.constraints.Constraint instance. When TAG is a
            %   string or a character vector, only the TestSuite array elements whose
            %   test tag exactly matches the text specified by TAG are retained. When
            %   TAG is a constraint, the TestSuite array element's test tag must
            %   satisfy the constraint in order to be retained.
            
            import matlab.unittest.constraints.IsAnything;
            import matlab.unittest.internal.selectors.convertInputToConstraint;
            
            if nargin < 1
                selector.Constraint = IsAnything;
            else
                selector.Constraint = convertInputToConstraint(tag,'Tag');
            end
        end
    end
end

% LocalWords:  mypackage

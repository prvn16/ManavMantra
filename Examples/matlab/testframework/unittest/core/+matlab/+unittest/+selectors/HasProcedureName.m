classdef (Sealed) HasProcedureName < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasProcedureName - Select TestSuite elements by procedure name.
    %
    %   The HasProcedureName selector filters TestSuite array elements based on
    %   the ProcedureName.
    %
    %   HasProcedureName methods:
    %       HasProcedureName - Class constructor
    %
    %   HasProcedureName properties:
    %       Constraint - Condition that the TestSuite ProcedureName must satisfy.
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasProcedureName; 
    %       import matlab.unittest.constraints.ContainsSubstring;
    %
    %       % Create a TestSuite to filter 
    %       suite = TestSuite.fromPackage('mypackage');
    %
    %       % Select a single TestSuite element by its procedure name. 
    %       newSuite = suite.selectIf(HasProcedureName('Test1'));
    %
    %       % Select all TestSuite elements whose procedure name contains
    %       "Test" 
    %       newSuite = suite.selectIf(HasProcedureName(ContainsSubstring('Test')));
    %
    %  Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Constraint
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.ProcedureNameAttribute';
        AttributeAcceptMethodName char = 'acceptsProcedureName';
    end
    
    methods
        function selector = HasProcedureName(procedureName)
            % HasProcedureName - Class constructor
            %
            %   selector = HasProcedureName(PROCEDURENAME) creates a selector that
            %   filters TestSuite array elements based on PROCEDURENAME. PROCEDURENAME
            %   can be either a string, character vector, or a
            %   matlab.unittest.constraints.Constraint instance. When PROCEDURENAME is
            %   a string or a character vector, only the TestSuite array elements whose
            %   ProcedureName exactly matches the text specified by PROCEDURENAME are
            %   retained. When PROCEDURENAME is a constraint, the TestSuite array
            %   element's ProcedureName must satisfy the constraint in order to be
            %   retained.
            
            import matlab.unittest.internal.selectors.convertInputToConstraint;
            selector.Constraint = convertInputToConstraint(procedureName,'ProcedureName');
        end
    end
    
end


classdef(Hidden,HandleCompatible) NegatableConstraint < matlab.unittest.constraints.Constraint
    % This class is undocumented and may change in a future release.
    
    % NegatableConstraint - Interface for Constraints that can be negated
    %
    %   The NegatableConstraint interface is a sub-interface of Constraint
    %   which allows constraints to negated. In particular, any constraint
    %   which derives from NegatableConstraint is able to be negated using
    %   the NOT (~) operator of the MATLAB language.
    %
    %   Classes which derive from the NegatableConstraint interface must
    %   implement everything required by the standard Constraint interface.
    %   In addition, it also must provide a means to provide a Diagnostic
    %   for the negative case. This is because when a given constraint is
    %   negated the diagnostics must be provided or written in a different
    %   form than the form presented upon a standard (non-negated) failure.
    %   In exchange for meeting these requirements, all NegatableConstraint
    %   implementations inherit the appropriate MATLAB overload NOT.
    %
    %   NegatableConstraint methods:
    %       getNegativeDiagnosticFor - produce a negated diagnostic for a value
    %       not - the logical negation of a negatable constraint
    %
    %   See also
    %       matlab.unittest.constraints.BooleanConstraint
    %       matlab.unittest.internal.constraints.CombinableConstraint
    %       matlab.unittest.diagnostics.Diagnostic
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods(Abstract, Access=protected)
        % getNegativeDiagnosticFor - produce a negated diagnostic for a value
        %
        %   DIAG = getNegativeDiagnosticFor(CONSTRAINT, ACTUAL) analyzes the ACTUAL
        %   value provided against the CONSTRAINT, produces a
        %   matlab.unittest.diagnostics.Diagnostic object which corresponds to the
        %   negation of the CONSTRAINT, and returns that object as DIAG.
        %
        %   This method is only called by the NegatableConstraint infrastructure upon
        %   encountering a qualification failure. However, Constraint authors who
        %   wish to opt in to negatable constraints need to define this method in
        %   their constraints. The diagnostics that this method should produce must
        %   be expressed in the negative sense of the constraint that they apply
        %   to. For example, a hypothetical IsTasty constraint, when negated,
        %   should express that the actual value was "tasty", when it should not
        %   have been, and it should describe the details on why it was found to be
        %   tasty.
        %
        %   Like the getDiagnosticFor method of Constraint, it is only called upon
        %   failures, and thus has the luxury of a more detailed analysis than the
        %   satisfiedBy method if that analysis produces helpful diagnostics.
        %
        %   See also
        %       getDiagnosticFor
        %       not
        %       satisfiedBy
        %       matlab.unittest.diagnostics.Diagnostic
        diag = getNegativeDiagnosticFor(constraint, actual);
    end
    
    methods (Sealed)
        function constraint = not(constraint)
            % not - the logical negation of a negatable constraint
            %
            %   not(CONSTRAINT) returns a constraint that is precisely the boolean
            %   complement of the CONSTRAINT provided. This is a means to specify that
            %   the CONSTRAINT should not be satisfied by the actual value provided,
            %   and that a qualification failure should be produced when the CONSTRAINT
            %   is satisfied.
            %
            %   Typically, the NOT method is not called directly, but the MATLAB "~"
            %   operator is used to denote the negation of any given NegatableConstraint.
            %
            %   Upon encountering a failure, the resulting constraint diagnostics
            %   produced will be retrieved through the getNegativeDiagnosticFor method.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.HasNaN;
            %       import matlab.unittest.constraints.IsEmpty;
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       import matlab.unittest.constraints.IsReal;
            %       import matlab.unittest.constraints.IsOfClass;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Passing qualifications
            %       testCase.verifyThat(3, ~IsEqualTo(4));
            %       testCase.assertThat('Some char', ~IsInstanceOf(?double));
            %       testCase.assumeThat(3, ~HasNaN);
            %
            %       % Failing qualifications
            %       testCase.verifyThat(3, ~IsReal);
            %       testCase.assertThat('Some char', ~IsOfClass('char'));
            %       testCase.testCase.fatalAssertThat([], ~IsEmpty);
            %
            %   See also
            %       getNegativeDiagnosticFor
            %       matlab.unittest.constraints.BooleanConstraint
            %
            
            import matlab.unittest.constraints.NotConstraint;
            
            if isa(constraint, 'NotConstraint')
                constraint = constraint.Constraint;
            else
                constraint = NotConstraint(constraint);
            end
        end
    end
end
% LocalWords:  negatable

classdef BooleanConstraint < matlab.unittest.internal.constraints.CombinableConstraint & ...
                             matlab.unittest.internal.constraints.NegatableConstraint
    % BooleanConstraint - Interface for boolean combinations of Constraints
    %
    %   The BooleanConstraint interface is a sub-interface of Constraint which
    %   allows constraints to be combined to form a boolean algebra. In
    %   particular, any constraint which derives from BooleanConstraint is able
    %   to be combined and negated using the AND (&), OR (|), and NOT (~)
    %   operators of the MATLAB language.
    %
    %   Classes which derive from the BooleanConstraint interface must
    %   implement everything required by the standard Constraint interface. In
    %   addition, it also must provide a means to provide a Diagnostic for the
    %   negative case. This is because when a given constraint is negated the
    %   diagnostics must be provided or written in a different form than the
    %   form presented upon a standard (non-negated) failure.
    %
    %   In exchange for meeting these requirements, all BooleanConstraint
    %   implementations inherit the appropriate MATLAB overloads for AND, OR,
    %   and NOT so that they can be combined with other BooleanConstraints to
    %   form a full boolean algebra.
    %
    %   BooleanConstraint methods:
    %       getNegativeDiagnosticFor - produce a negated diagnostic for a value
    %       not - the logical negation of a boolean constraint
    %       and - the logical conjunction of a boolean constraint
    %       or - the logical disjunction of a boolean constraint
    %
    %   Examples:
    %
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   % BooleanConstraint Usage (see definition of HasSameSizeAs below)
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   import matlab.unittest.constraints.HasLength;
    %   import matlab.unittest.TestCase;
    %
    %   % Create a TestCase for interactive use
    %   testCase = TestCase.forInteractiveUse;
    %
    %   % Passing verification
    %   testCase.verifyThat([1 2], HasLength(2) | ~HasSameSizeAs(zeros(1, 2))); % Passes because one of them passes (OR)
    %
    %   % Failing assertion
    %   testCase.assertThat([1 2], HasLength(2) & ~HasSameSizeAs(zeros(1, 2))); % Fails because one of them fails (AND)
    %
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % BooleanConstraint definition
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % classdef HasSameSizeAs < matlab.unittest.constraints.BooleanConstraint
    %     % HasSameSizeHas - an example boolean constraint
    %     %
    %     %   Simple example to demonstrate how to create a custom
    %     %   constraint. This constraint determines whether a
    %     %   given value is the same size as some expected value.
    %     %
    %     %   It is suggested to make BooleanConstraint implementations immutable
    %     %   (unchangeable) after construction, which is why the example
    %     %   property is private.
    %
    %     properties(Access=private)
    %
    %         % ValueOfExpectedSize - an expected value with which to compare sizes
    %         ValueWithExpectedSize
    %     end %properties
    %
    %     methods(Access=private)
    %         function bool = sizeMatchesExpected(constraint, actual)
    %             bool = isequal(size(actual), size(constraint.ValueWithExpectedSize));
    %         end
    %     end
    %
    %     % Implement the Abstract protected method required by BooleanConstraint
    %     methods(Access=protected)
    %
    %         function diag = getNegativeDiagnosticFor(constraint, actual)
    %             % getNegativeDiagnosticFor - produce a diagnostic when the constraint is incorrectly met
    %             %
    %             %   This method is called by the testing framework when the constraint has
    %             %   been met but should not have been met because it was negated in a
    %             %   boolean expression. It should produce a Diagnostic result that
    %             %   describes the failure in the correct terms which express the
    %             %   requirement that the constraint actually should not have been met.
    %
    %             import matlab.unittest.diagnostics.StringDiagnostic;
    %
    %             if constraint.sizeMatchesExpected(actual)
    %                 % Create the negative diagnostic. This will show information such as the
    %                 % constraint class name and display the raw actual and expected values.
    %                 % Using the DiagnosticSense.NegativeDiagnostic enumeration also
    %                 % produces language more appropriate for the negated case.
    %                 diag = StringDiagnostic(sprintf(...
    %                     'Negated HasSameSizeAs failed.\nSize [%s] of Actual Value and Expected Value were the same but should not have been.',...
    %                     int2str(size(actual))));
    %             else
    %                 % Produce a passing diagnostic, with language appropriate for the negated case
    %                 diag = StringDiagnostic('Negated HasSameSizeAs passed.');
    %             end %if
    %
    %         end %function
    %     end
    %
    %     methods
    %
    %         function constraint = HasSameSizeAs(value)
    %             % Constructor - construct an HasSameSizeAs constraint
    %             %
    %             %   The HasSameSizeAs constructor takes the value to compare size against
    %             %   and stores this value in the ValueWithExpectedSize property.
    %
    %             constraint.ValueWithExpectedSize = value;
    %         end %function
    %
    %         function bool = satisfiedBy(constraint, actual)
    %             % satisfiedBy - Determine whether a value is the same size as an expected.
    %             %
    %             %   The satisfiedBy method should be a fast determination of whether or not
    %             %   the constraint was met by the actual value provided. This method should
    %             %   be as fast as possible, optimized for the passing case.
    %
    %             bool = constraint.sizeMatchesExpected(actual);
    %         end %function
    %
    %         function diag = getDiagnosticFor(constraint, actual)
    %             % getDiagnosticFor - produce a diagnostic when the constraint is not met
    %             %
    %             %   This method can be called by the testing framework when the constraint
    %             %   has not been met. Unlike the satisfiedBy method, performance is not a
    %             %   primary goal. Rather, a thorough analysis should be performed to
    %             %   determine the reason the constraint was not satisfied. Using the
    %             %   information from this analysis, this method is required to produce a
    %             %   Diagnostic for the framework to present to the user.
    %
    %             import matlab.unittest.diagnostics.StringDiagnostic;
    %
    %             if constraint.sizeMatchesExpected(actual)
    %                 % Create a passing diagnostic
    %                 diag = StringDiagnostic('HasSameSizeAs passed.');
    %             else
    %                 diag = StringDiagnostic(sprintf('HasSameSizeAs failed.\nActual Size: [%s]\nExpectedSize: [%s]', ...
    %                     int2str(size(actual)), int2str(size(constraint.ValueWithExpectedSize))));
    %             end %if
    %
    %         end %function
    %
    %     end %methods
    %
    % end %classdef
    %
    %   See also
    %       matlab.unittest.diagnostics.Diagnostic
    
    %  Copyright 2010-2016 The MathWorks, Inc.
end

% LocalWords:  Negatable

classdef(HandleCompatible) Constraint
    % Constraint - Fundamental interface for comparisons
    %
    %   The Constraint interface is the means by which matlab.unittest
    %   constraints encode comparison logic and its corresponding diagnostic
    %   information. Every comparison that can conditionally produce a failure
    %   is built off of the Constraint interface.
    %
    %   Classes which derive from the Constraint interface must provide a means
    %   to determine whether a given value satisfies the constraint, which is
    %   where the underlying comparison logic is defined. It also must provide
    %   a diagnostic for any given actual value which can be utilized by the
    %   testing framework when a qualification failure has been encountered.
    %
    %   In exchange for meeting these requirements, all Constraint
    %   implementations can be easily plugged into all qualification types
    %   (i.e. verifications, assertions, fatal assertions, assumptions, etc.)
    %   which can then utilize the comparison and diagnostic knowledge
    %   contained within the constraints. Also, the constraints can also be
    %   used in situations where a test failure is not desired, but the
    %   comparison logic they contain needs to be reused. For example, a
    %   constraint implementation may want to use the logic defined inside of
    %   another constraint, and it can do so without the potential of causing a
    %   qualification failure by simply interacting with the other constraint
    %   directly.
    %
    %   Constraint methods:
    %       satisfiedBy - determine whether a value satisfies the constraint
    %       getDiagnosticFor - produce a diagnostic for a value
    %
    %   Examples:
    %
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   % Constraint Usage (see definition of HasSameSizeAs below)
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   import matlab.unittest.TestCase;
    %
    %   % Create a TestCase for interactive use
    %   testCase = TestCase.forInteractiveUse;
    %
    %   % Passing verification
    %   testCase.verifyThat([1 2], HasSameSizeAs(zeros(1, 2)));
    %
    %   % Failing assertion
    %   testCase.assertThat(1, HasSameSizeAs(zeros(1, 2)));
    %
    %
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Constraint definition
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % classdef HasSameSizeAs < matlab.unittest.constraints.Constraint
    %     % HasSameSizeHas - an example constraint
    %     %
    %     %   Simple example to demonstrate how to create a custom constraint. This
    %     %   constraint determines whether a given value is the same size as some
    %     %   expected value.
    %     %
    %     %   It is suggested to make Constraint implementations immutable
    %     %   (unchangeable) after construction, which is why the example property
    %     %   has SetAccess=immutable.
    %
    %     properties(SetAccess=immutable)
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
    %     methods
    %
    %         function constraint = HasSameSizeAs(value)
    %             % Constructor - construct a HasSameSizeAs constraint
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
    %       matlab.unittest.diagnostics.ConstraintDiagnostic
    %       matlab.unittest.qualifications.Assertable.assertThat
    %       matlab.unittest.qualifications.Assumable.assumeThat
    %       matlab.unittest.qualifications.FatalAssertable.fatalAssertThat
    %       matlab.unittest.qualifications.Verifiable.verifyThat
    
    %  Copyright 2010-2016 The MathWorks, Inc.

    
    methods(Abstract)
        % satisfiedBy - determine whether a value satisfies the constraint
        %
        %   TF = satisfiedBy(CONSTRAINT, ACTUAL) returns a scalar logical value in
        %   TF to designate whether the ACTUAL value meets the CONSTRAINT which has
        %   defined the method.
        %
        %   The satisfiedBy method is the method which defines the precise logic to
        %   determine whether the actual value meets the constraint. The
        %   satisfiedBy method is used to determine qualification success or
        %   failure.
        %
        %   This method should be optimized for speed in the passing case, since
        %   that will be the most common usage, and it is only in the failing
        %   case that more expensive detailed analysis could be helpful.
        %
        %   See also
        %       getDiagnosticFor
        tf = satisfiedBy(constraint, actual);
        
        % getDiagnosticFor - produce a diagnostic for a value
        %
        %   DIAG = getDiagnosticFor(CONSTRAINT, ACTUAL) analyzes the ACTUAL value
        %   provided against the CONSTRAINT, produces an object that is of type
        %   matlab.unittest.diagnostics.Diagnostic, and returns that object as
        %   DIAG.
        %
        %   This method is typically called by the testing framework upon
        %   encountering a qualification failure. Since it is typically called upon
        %   failures, it can afford to undertake a more detailed analysis than the
        %   satisfiedBy method if that analysis produces helpful diagnostics.
        %
        %   Though the requirement of implementors is to return Diagnostics, it is
        %   preferable to return these diagnostics as ConstraintDiagnostics.
        %   Benefits of doing so include:
        %
        %       1)  It ensures that diagnostics returned by Constraints have a
        %           common feel across different Constraint implementations. 
        %
        %       2)  ConstraintDiagnostics integrate more seamlessly with other
        %           matlab.unittest constructs such as BooleanConstraints,
        %           Comparators, and ActualValueProxies.
        %
        %   See also
        %       satisfiedBy
        %       matlab.unittest.diagnostics.Diagnostic
        %       matlab.unittest.diagnostics.ConstraintDiagnostic 
        diag = getDiagnosticFor(constraint, actual);
    end
    
    methods(Hidden, Access=protected)
        function c = Constraint
            % Constructor needs to be protected
        end
    end
    
end


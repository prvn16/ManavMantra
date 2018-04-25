classdef IsEqualTo < matlab.unittest.constraints.BooleanConstraint & ...
                     matlab.unittest.internal.constraints.CasualDiagnosticMixin & ...
                     matlab.unittest.internal.constraints.CasualNegativeDiagnosticMixin & ...
                     matlab.unittest.internal.mixin.WithinMixin & ...
                     matlab.unittest.internal.mixin.IgnoringCaseMixin & ...
                     matlab.unittest.internal.mixin.IgnoringWhitespaceMixin & ...
                     matlab.unittest.internal.mixin.IgnoringFieldsMixin & ...
                     matlab.unittest.internal.mixin.NameValueForwarderMixin
    % IsEqualTo - General constraint used to compare various MATLAB types
    %
    %   The IsEqualTo constraint compares the following object types for
    %   equality:
    %
    %      * Numerics
    %      * Strings or Character arrays
    %      * Logicals
    %      * Structures
    %      * Cell arrays
    %      * Tables
    %      * MATLAB & Java Objects
    %
    %   The type of comparison used is governed by the type of the expected
    %   value. The first check performed is to check whether the expected value
    %   is an object. This check is performed first because in this case it is
    %   possible for the object to have overridden methods that are used in
    %   subsequent checks (e.g. islogical). The following list categorizes and
    %   describes the various tests in the order they are performed:
    %
    %   [Numerics] If the expected value is numeric, the actual and expected
    %   values are checked for equivalent class, size, and sparsity. If all of
    %   these checks match, isequaln is used. If isequaln returns true, the
    %   constraint is satisfied. If the complexity does not match or isequaln
    %   returns false, and a supported tolerance has been supplied, it is used
    %   to perform the comparison. Otherwise, the constraint is not satisfied.
    %
    %   [Strings or Character arrays] If the expected value is a string or a
    %   character array, the strcmp function is used to check the actual and
    %   expected values for equality unless IgnoreCase is true, in which case
    %   the values are compared using strcmpi. If IgnoreWhitespace is true,
    %   all whitespace characters are removed from the actual and expected
    %   values before passing them to strcmp or strcmpi.
    %
    %   [Logicals] If the expected value is a logical, the actual and expected
    %   values are checked for equivalent class, size, and sparsity. If the
    %   class, size, and sparsity matches, the values are compared using the
    %   isequal method. Otherwise, the constraint is not satisfied.
    %
    %   [Structures] If the expected value is a struct, the field count of the
    %   actual and expected values is compared. Fields listed in IgnoredFields
    %   are not included in the count. If not equal, the constraint is not
    %   satisfied. Otherwise, each field of the expected value struct that is
    %   not listed in IgnoredFields must exist on the actual value struct. If
    %   any field names are different, the constraint is not satisfied. The
    %   fields are then recursively compared. The recursion continues until a
    %   fundamental data type is encountered (i.e. logical, numeric, character
    %   array, string, or object), and the values are compared as described
    %   above. IsEqualTo does not compare the values of any fields listed in
    %   IgnoredFields.
    %
    %   [Cell Arrays] If the expected value is a cell array, the actual and
    %   expected values are checked for class and size equality. If they are
    %   not equal in class and size, the constraint is not satisfied.
    %   Otherwise, each element of the array is recursively compared in a
    %   manner identical to fields in a structure, described above.
    %
    %   [Tables] If the expected value is a table, the actual and expected
    %   values are checked for class equality, size equality, and for equal
    %   table properties. If they are not equal in class, size, or table
    %   properties, the constraint is not satisfied. Otherwise, each row of
    %   the table is recursively compared in a manner identical to fields
    %   in a structure, described above.
    %
    %   [MATLAB & Java Objects] If the expected value is a MATLAB or Java
    %   object, the IsEqualTo constraint calls either the isequaln or the
    %   isequal method on the expected value. The constraint uses isequal only
    %   if the class of the expected value defines an isequal method and does
    %   not define an isequaln method. Otherwise, it uses isequaln. If this
    %   comparison returns false and a supported tolerance has been specified,
    %   the actual and expected values are checked for equivalent size, class,
    %   and sparsity. If these checks fail, the constraint is not satisfied. If
    %   these checks pass, the tolerance is used for comparison.
    %
    %   IsEqualTo methods:
    %       IsEqualTo - Class constructor
    %
    %   IsEqualTo properties:
    %       Expected         - The expected value that will be compared to the actual value
    %       Comparator       - A matlab.unittest.constraints.Comparator object array
    %       Tolerance        - A matlab.unittest.constraints.Tolerance object
    %       IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %       IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %       IgnoredFields    - Fields to ignore
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.constraints.AbsoluteTolerance;
    %       import matlab.unittest.TestCase;
    %       import matlab.unittest.constraints.PublicPropertyComparator;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       %%% Simple equality check %%%
    %       testCase.verifyThat(5, IsEqualTo(5));
    %
    %       %%% Comparison using tolerance %%%
    %       testCase.assertThat(5, IsEqualTo(4.95, 'Within', AbsoluteTolerance(0.1)));
    %
    %       %%% Comparison ignoring case %%%
    %       testCase.fatalAssertThat('aBc', IsEqualTo('ABC', 'IgnoringCase', true));
    %
    %       %%% Comparison ignoring whitespace %%%
    %       testCase.assumeThat('a bc', IsEqualTo('ab c', 'IgnoringWhitespace', true));
    %
    %       %%% Comparison ignoring fields %%%
    %       testCase.assertThat(struct('a',1,'b',2,'c',3), ...
    %           IsEqualTo(struct('a',1,'b',0), 'IgnoringFields', {'b','c'}));
    %
    %       %%% Comparison using a specified comparator %%%
    %       testCase.verifyThat(MException('a:b','Hi'),...
    %           IsEqualTo(MException('a:b','Hi'),'Using',...
    %           PublicPropertyComparator.supportingAllValues()));
    %
    %   See also:
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.Tolerance
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Expected - The expected value that will be compared to the actual value
        Expected;
    end
    
    properties (SetAccess = private)
        % Comparator - A matlab.unittest.constraints.Comparator object array
        %
        %   When specified, the instance uses the specified comparator.
        %
        %   The comparator array can be specified during construction of the
        %   instance by utilizing the (..., 'Using', comparator) parameter
        %   value pair.
        Comparator (1,:) matlab.unittest.constraints.Comparator {mustBeNonempty} = ...
            matlab.unittest.constraints.IsEqualTo.DefaultComparator;
    end
    
    properties (Hidden, Constant)
        % DefaultComparator - A Comparator array which supports all MATLAB data types
        DefaultComparator = generateDefaultComparator();
    end
    
    properties (Access=private)
        IgnoringCaseWasProvided = false;
        IgnoringFieldsWasProvided = false;
        IgnoringWhitespaceWasProvided = false;
        WithinWasProvided = false;
    end
    
    methods
        function constraint = IsEqualTo(expectedValue, varargin)
            %IsEqualTo - Class constructor
            %
            %   IsEqualTo(EXPECTEDVALUE) creates a constraint that is able to determine
            %   whether an actual value is equal to EXPECTEDVALUE.
            %
            %   IsEqualTo(..., 'Within', TOL) creates a constraint that is able to
            %   determine whether an actual value is equal to EXPECTEDVALUE within the
            %   tolerance TOL.
            %
            %   IsEqualTo(..., 'IgnoringCase', true) creates a constraint that is able
            %   to determine whether an actual value is equal to EXPECTEDVALUE, while
            %   ignoring case differences.
            %
            %   IsEqualTo(..., 'IgnoringWhitespace', true) creates a constraint that is
            %   able to determine whether an actual value is equal to EXPECTEDVALUE,
            %   while ignoring whitespace differences.
            %
            %   IsEqualTo(..., 'IgnoringFields', FIELDSTOIGNORE) creates a constraint
            %   that is able to determine whether an actual value is equal to
            %   EXPECTEDVALUE, while ignoring any struct field with a name listed in
            %   the cell array FIELDSTOIGNORE.
            %
            %   IsEqualTo(...,'Using',COMPOBJ) creates a constraint that is able to
            %   determine whether an actual value is equal to EXPECTEDVALUE using a
            %   comparator, COMPOBJ.

            constraint.Expected = expectedValue;
            constraint = constraint.addNameValue('Using',@using);
            constraint = constraint.parse(varargin{:});
        end
        
        function bool = satisfiedBy(constraint, actual)
            bool = constraint.Comparator.satisfiedBy(actual,constraint.Expected);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            compDiag = constraint.Comparator.getDiagnosticFor(actual,constraint.Expected);

            if compDiag.Passed
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    constraint, DiagnosticSense.Positive, actual, constraint.Expected);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, actual, constraint.Expected);
            end
            
            if compDiag.DisplayValueReference
                compDiag.DisplayActVal = false;
                compDiag.DisplayExpVal = false;
                diag.ConditionsList = compDiag;
            else
                diag.DisplayActVal = false;
                diag.DisplayExpVal = false;
                diag.ConditionsList = compDiag.ConditionsList;
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            compDiag = constraint.Comparator.getDiagnosticFor(actual,constraint.Expected);
            
            if compDiag.Passed
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Negative, actual, constraint.Expected);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    constraint, DiagnosticSense.Negative, actual, constraint.Expected);
            end
            
            if compDiag.DisplayValueReference
                compDiag.DisplayActVal = false;
                compDiag.DisplayExpVal = false;
                diag.ConditionsList = compDiag;
            else
                diag.DisplayActVal = false;
                diag.DisplayExpVal = false;
                diag.ConditionsList = compDiag.ConditionsList;
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods (Hidden)
        function diag = getCasualDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            compDiag = constraint.Comparator.getCasualDiagnosticFor(actual,constraint.Expected);

            if compDiag.Passed
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    constraint, DiagnosticSense.Positive, actual, constraint.Expected);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, actual, constraint.Expected);
            end
            
            if compDiag.DisplayValueReference
                diag.ConditionsList = compDiag;
            else
                %These lines are required due to NumericComparator wanting to
                %modify the display of its ActVal and ExpVal:
                diag.ActVal = compDiag.ActVal;
                diag.ExpVal = compDiag.ExpVal;
                
                diag.ConditionsList = compDiag.ConditionsList;
            end
        end
    end
        
    methods (Hidden, Access = protected)
        function diag = getCasualNegativeDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            compDiag = constraint.Comparator.getCasualDiagnosticFor(actual,constraint.Expected);

            if compDiag.Passed
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Negative, actual, constraint.Expected);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    constraint, DiagnosticSense.Negative, actual, constraint.Expected);
            end
            
            if compDiag.DisplayValueReference
                diag.ConditionsList = compDiag;
            else
                %These lines are required due to NumericComparator wanting to
                %modify the display of its ActVal and ExpVal:
                diag.ActVal = compDiag.ActVal;
                diag.ExpVal = compDiag.ExpVal;
                
                diag.ConditionsList = compDiag.ConditionsList;
            end
        end
    end
    
    methods (Hidden, Sealed)
        function constraint = using(constraint, comparator)
            constraint.Comparator = comparator;
            comparator.validateSupportsContainer(constraint.Expected);
            
            if constraint.IgnoringCaseWasProvided
                constraint = constraint.forwardNameValue(...
                    'IgnoringCase',constraint.IgnoreCase);
            end
            if constraint.IgnoringWhitespaceWasProvided
                constraint = constraint.forwardNameValue(...
                    'IgnoringWhitespace',constraint.IgnoreWhitespace);
            end
            if constraint.WithinWasProvided
                constraint = constraint.forwardNameValue(...
                    'Within',constraint.Tolerance);
            end
            if constraint.IgnoringFieldsWasProvided
                constraint = constraint.forwardNameValue(...
                    'IgnoringFields',constraint.IgnoredFields);
            end
        end
    end
    
    methods (Hidden, Sealed, Access = protected)
        function constraint = forwardNameValue(constraint, paramName, paramValue)
            %forwardNameValue - required implementation for NameValueForwarderMixin
            comparator = constraint.Comparator;
            for k=1:numel(comparator)
                comparator(k) = constraint.applyNameValueTo(comparator(k),paramName, paramValue);
            end
            constraint.Comparator = comparator;
        end
        
        function constraint = ignoringCasePostSet(constraint)
            constraint.IgnoringCaseWasProvided = true;
            constraint = constraint.forwardNameValue(...
                'IgnoringCase',constraint.IgnoreCase);
        end
        
        function constraint = ignoringWhitespacePostSet(constraint)
            constraint.IgnoringWhitespaceWasProvided = true;
            constraint = constraint.forwardNameValue(...
                'IgnoringWhitespace',constraint.IgnoreWhitespace);
        end
        
        function constraint = withinPostSet(constraint)
            constraint.WithinWasProvided = true;
            constraint = constraint.forwardNameValue(...
                'Within',constraint.Tolerance);
        end
        
        function constraint = ignoringFieldsPostSet(constraint)
            constraint.IgnoringFieldsWasProvided = true;
            constraint = constraint.forwardNameValue(...
                'IgnoringFields',constraint.IgnoredFields);
        end
    end
end
        

function comparator = generateDefaultComparator()
import matlab.unittest.constraints.NumericComparator;
import matlab.unittest.constraints.StringComparator;
import matlab.unittest.constraints.LogicalComparator;
import matlab.unittest.constraints.StructComparator;
import matlab.unittest.constraints.CellComparator;
import matlab.unittest.constraints.TableComparator;
import matlab.unittest.constraints.ObjectComparator;
comparator = [...
    NumericComparator(),...
    StringComparator(),...
    LogicalComparator(),...
    StructComparator('IncludingSelf',true,'IncludingSiblings',true),...
    CellComparator('IncludingSelf',true,'IncludingSiblings',true),...
    TableComparator('IncludingSelf',true,'IncludingSiblings',true),...
    ObjectComparator()];
end

% LocalWords:  Bc bc EXPECTEDVALUE FIELDSTOIGNORE COMPOBJ

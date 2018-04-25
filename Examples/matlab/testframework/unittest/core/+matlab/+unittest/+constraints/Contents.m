% matlab.unittest.constraints
%
%   Constraints are the mechanism which are employed to specify business
%   rules against which to qualify a calculated value. Constraints are to
%   be used in conjunction with qualifications through the
%   assertThat/assumeThat/fatalAssertThat/verifyThat methods on TestCase.
%   Constraints encode whether or not any calculated (i.e. actual) value
%   satisfies the constraint. Also, it can provide diagnostics for any
%   value in the event the constraint is not satisfied by the value.
%
%
% Fundamental Constraint Related Interfaces
% -----------------------------------------
%   Constraint         - Fundamental interface for comparisons
%   BooleanConstraint  - Interface for boolean combinations of Constraints
%
%
% Constraint Implementations
% --------------------------
%   General Purpose:
%       IsAnything      - Constraint specifying anything
%       IsTrue          - Constraint specifying a true value
%       IsFalse         - Constraint specifying a false value
%       IsEqualTo       - General constraint used to compare various MATLAB types
%       IsSameHandleAs  - Constraint specifying the same handle instance(s) to another
%       ReturnsTrue     - Constraint specifying a function handle that returns true
%       Eventually      - Poll for a value to asynchronously satisfy a constraint
%       HasField        - Constraint specifying a structure containing the mentioned field name
%
%   Errors & Warnings:
%       Throws            - Constraint specifying a function handle that throws an MException
%       IssuesWarnings    - Constraint specifying a function that issues an expected warning profile
%       IssuesNoWarnings  - Constraint specifying a function handle that issues no warnings
%
%   Inequalities:
%       IsGreaterThan           - Constraint specifying a value greater than another value
%       IsGreaterThanOrEqualTo  - Constraint specifying a value greater than or equal to another value
%       IsLessThan              - Constraint specifying a value less than another value
%       IsLessThanOrEqualTo     - Constraint specifying a value less than or equal to another value
%
%   Array Size:
%       IsEmpty          - Constraint specifying an empty value
%       IsScalar         - Constraint specifying a scalar value
%       HasLength        - Constraint specifying an expected length of an array
%       HasSize          - Constraint specifying an expected size of an array
%       HasElementCount  - Constraint specifying an expected number of elements
%
%   Type:
%       IsInstanceOf  - Constraint specifying inclusion in a given class hierarchy
%       IsOfClass     - Constraint specifying a given exact type
%
%   Strings & Character Vectors:
%       ContainsSubstring    - Constraint specifying a string or character vector containing a given substring
%       IsSubstringOf        - Constraint specifying a substring of a given string or character vector
%       EndsWithSubstring    - Constraint specifying a string or character vector ending with a given substring
%       StartsWithSubstring  - Constraint specifying a string or character vector starting with a given substring
%       Matches              - Constraint specifying a string or character vector matching a given regular  expression
%
%   Finiteness:
%       HasNaN    - Constraint specifying an array containing a NaN value
%       HasInf    - Constraint specifying an array containing any infinite value
%       IsFinite  - Constraint specifying a finite value
%
%   Numeric Attributes:
%       IsReal    - Constraint specifying a real valued array
%       IsSparse  - Constraint specifying a sparse array
%
%   Sets:
%       HasUniqueElements  - Constraint specifying a set that contains unique elements
%       IsSameSetAs        - Constraint specifying a set that contains the same elements as another set
%       IsSubsetOf         - Constraint specifying a subset of another set
%       IsSupersetOf       - Constraint specifying a superset of another set
%
%   Files & Folders:
%       IsFile    - Constraint specifying a string or character vector which points to a file
%       IsFolder  - Constraint specifying a string or character vector which points to a folder
%
%
% ActualValueProxies
% ------------------
%   AnyElementOf    - Test if any element of a matrix value meets a constraint
%   EveryElementOf  - Test if all elements of a matrix value meet a constraint
%   AnyCellOf       - Test if any cell of a cell array meets a constraint
%   EveryCellOf     - Test if all cells of a cell array meet a constraint
%
%
% Tolerances & Comparators
% -----------------------
%   Tolerances:
%       Tolerance           - Abstract interface for tolerances
%       AbsoluteTolerance   - Absolute numeric tolerance
%       RelativeTolerance   - Relative numeric tolerance
%
%   Comparators:
%       Comparator                - Abstract interface for comparators
%       CellComparator            - Comparator for comparing MATLAB cell arrays
%       LogicalComparator         - Comparator for comparing two MATLAB logical values
%       NumericComparator         - Comparator for comparing MATLAB numeric data types
%       ObjectComparator          - Comparator for comparing two MATLAB or Java objects
%       PublicPropertyComparator  - Comparator for comparing the public properties of MATLAB objects
%       StringComparator          - Comparator for comparing MATLAB strings or character vectors
%       StructComparator          - Comparator for comparing MATLAB structs
%       TableComparator           - Comparator for comparing MATLAB tables
%
%__________________________________________________________________________

%   Copyright 2012-2017 The MathWorks, Inc.
classdef ConstraintDiagnosticFactory
    %ConstraintDiagnosticFactory   Generates ConstraintDiagnostic objects
    %   This class provides static methods that assist with generating
    %   matlab.unittest.diagnostics.ConstraintDiagnostic objects. The primary
    %   use case is for the return value of the getDiagnosticFor() and
    %   getNegativeDiagnosticFor() methods when developing classes derived from
    %   matlab.unittest.constraints.Constraint or matlab.unittest.constraints.Comparator.
    %   The matlab.unittest.internal.diagnostics.DiagnosticSense
    %   enumeration defines the enumerations for positive and negative diagnostics.
    %
    %   See also
    %       matlab.unittest.internal.diagnostics.DiagnosticSense
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.diagnostics.ConstraintDiagnostic
    
    %   Copyright 2010-2017 The MathWorks, Inc.
    
    properties (Access = private, Constant)
        MessageCatalog = matlab.internal.Catalog('MATLAB:unittest:ConstraintDiagnosticFactory');
    end
    
    
    methods (Static, Access = private)
        function diag = createGenericDiagnostic(requirement, isSatisfied, consType, actVal, expVal)
            %createGenericDiagnostic   Create diagnostic from a generic template
            %   DIAG = createGenericDiagnostic(REQUIREMENT, ISSATISFIED, CONSTYPE,
            %   ACTVAL, EXPVAL) creates a generic positive or negated
            %   ConstraintDiagnostic, DIAG, for the constraint or comparator defined by
            %   REQUIREMENT. The ISSATISFIED flag determines whether the DIAG says it
            %   passed or not. The CONSTYPE is the PositiveDiagnostic or
            %   NegativeDiagnostic enumeration, which determines whether the DIAG is
            %   being generated for a positive (getDiagnosticFor) or negated
            %   (getNegativeDiagnosticFor) situation. ACTVAL and EXPVAL are the actual
            %   and expected values of the constraint or comparator.  When ACTVAL is
            %   omitted, the DisplayActVal property of the returned DIAG is turned off.
            %   When EXPVAL is omitted, the DisplayExpVal property of the returned DIAG
            %   is turned off.
            %
            %   This is a private method wrapped by more convenient public methods.
            
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            validateattributes(requirement, ...
                {'matlab.unittest.constraints.Constraint', ...
                'matlab.unittest.constraints.Comparator', ...
                'matlab.unittest.constraints.Tolerance', ...
                'matlab.unittest.constraints.ActualValueProxy'}, ...
                {'scalar'}, '', 'constraint');
            validateattributes(consType, ...
                {'matlab.unittest.internal.diagnostics.DiagnosticSense'}, ...
                {'scalar'}, '', 'consType');
            
            isNegated = consType == DiagnosticSense.Negative;
            
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            diag = ConstraintDiagnostic();
            diag.Passed = isSatisfied;
            diag.DisplayDescription = true;
            diag.Description = createConstraintDiagnosticDescription(requirement, isSatisfied, consType);
            diag.DisplayConditions = true;
            
            if nargin > 3
                diag.DisplayActVal = true;
                diag.ActVal = actVal;
                if builtin('ischar', actVal)
                    diag.ActValHeader = catalog.getString('ActualValueWithType',class(actVal));
                end % else, default header
            end
            
            if nargin > 4
                diag.DisplayExpVal = true;
                diag.ExpVal = expVal;
                expValIsChar = builtin('ischar', expVal);
                if isNegated && expValIsChar
                    diag.ExpValHeader = catalog.getString('ProhibitedValueWithType',class(expVal));
                elseif isNegated
                    diag.ExpValHeader = catalog.getString('ProhibitedValue');
                elseif expValIsChar
                    diag.ExpValHeader = catalog.getString('ExpectedValueWithType',class(expVal));
                end % else, default header
            end
        end
        
        function diag = constructFailureTableDiagnostic(failureTableHeader, failedIndices, actVal, expVal, tolTypes, tolVals)
            %constructFailureTableDiagnostic   Construct failure table diagnostic
            %   DIAG = constructFailureTableDiagnostic(HEADER, FAILEDINDICES, ACT, EXP, TOLVAL, TOLTYPE)
            %   creates a failure table given the actual, expected,
            %   tolerance values and failing indices. It then constructs a
            %   ConstraintDiagnostic from that failure table.
            
            %   This is a private method wrapped by more convenient public methods.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.TableDiagnostic;
            
            % Start with an empty table and add appropriate columns
            failureTable = table;
            
            % Get the message catalog
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            % Add non-scalar columns such as Index and Subscripts
            if ~isscalar(expVal)
                failureTable = addNonScalarColumns(failureTable, failedIndices, expVal);
            end
            
            [actVal, expVal, tolVals{:}] = selectAndColumnize(failedIndices, actVal, expVal, tolVals{:});
            
            failureTable.(catalog.getString('FailureTableActVal')) = actVal;
            failureTable.(catalog.getString('FailureTableExpVal')) = expVal;
            
            
            % Add appropriate error columns. For complex integer values, we cannot
            % perform any arithmetic and hence cannot compute absolute error.
            if isfloat(expVal)
                % For floating point values, show error and relative error
                failureTable.(catalog.getString('FailureTableError'))         = actVal - expVal;
                failureTable.(catalog.getString('FailureTableRelativeError')) = (actVal - expVal)./expVal;
            elseif isreal(expVal) && isreal(actVal)
                % For non-floating point real values, show the absolute error
                failureTable.(catalog.getString('FailureTableAbsoluteError')) = max(abs(actVal-expVal), abs(expVal-actVal));
            end
            
            % Add tolerance columns
            failureTable = [failureTable table(tolVals{:}, 'VariableNames', tolTypes)];
            diag = TableDiagnostic(failureTable, failureTableHeader);
        end
    end
    
    methods (Static)
        function diag = generatePassingDiagnostic(requirement, consType, varargin)
            %generatePassingDiagnostic   Generate a generic passing ConstraintDiagnostic
            %   DIAG = generatePassingDiagnostic(REQUIREMENT,CONSTYPE, ACTVAL, EXPVAL)
            %   generates a passing ConstraintDiagnostic.  When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called from
            %   getNegativeDiagnosticFor(), it should be the DiagnosticSense.Negative
            %   enumeration. ACTVAL and EXPVAL are the actual and expected (specified)
            %   values from the constraint. If ACTVAL is omitted, the generated DIAG
            %   turns off the DisplayActVal property. If EXPVAL is omitted, the
            %   generated DIAG turns off the DisplayExpVal property.
            %
            %   Examples:
            %       % From within a Constraint's getDiagnosticFor() method
            %       function diag = getDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               diag = ConstraintDiagnosticFactory.generatePassingDiagnostic( ...
            %                   constraint, DiagnosticSense.Positive, ...
            %                   actual,...  %optional
            %                   expected);  %optional
            %           else
            %               ... see help on generateFailingDiagnostic()
            %           end
            %       end
            %
            %       % From within a Constraint's getNegativeDiagnosticFor() method
            %       function diag = getNegativeDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               ... see help on generateFailingDiagnostic()
            %           else
            %               diag = ConstraintDiagnosticFactory.generatePassingDiagnostic( ...
            %                   constraint, DiagnosticSense.Negative, ...
            %                   actual,...  %optional
            %                   expected);  %optional
            %           end
            %       end
            %
            %   See also
            %       matlab.unittest.constraints.Constraint,
            %       matlab.unittest.constraints.Comparator,
            %       matlab.unittest.diagnostics.ConstraintDiagnostic,
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            diag = ConstraintDiagnosticFactory.createGenericDiagnostic(requirement, true, consType, varargin{:});
        end
        
        function diag = generateFailingDiagnostic(requirement, consType, varargin)
            %generateFailingDiagnostic   Generate a generic failing ConstraintDiagnostic
            %   DIAG = generateFailingDiagnostic(REQUIREMENT,CONSTYPE, ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic. When called from a
            %   getDiagnosticFor() method, CONSTYPE should be the
            %   DiagnosticSense.Positive enumeration; when called from
            %   getNegativeDiagnosticFor(), it should be the DiagnosticSense.Negative
            %   enumeration. ACTVAL and EXPVAL are the actual and expected (specified)
            %   values from the constraint. If ACTVAL is omitted, the generated DIAG
            %   turns off the DisplayActVal property. If EXPVAL is omitted, the
            %   generated DIAG turns off the DisplayExpVal property.
            %
            %   Examples:
            %       % From within a Constraint's getDiagnosticFor() method
            %       function diag = getDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               ... see help on generatePassingDiagnostic()
            %           else
            %               diag = ConstraintDiagnosticFactory.generateFailingDiagnostic( ...
            %                   constraint, ...
            %                   DiagnosticSense.Positive, ...
            %                   actual, ...  %optional
            %                   expected);   %optional
            %               ... make modifications to diag
            %               ... see help on matlab.unittest.diagnostics.ConstraintDiagnostic
            %           end
            %       end
            %
            %       % From within a Constraint's getNegativeDiagnosticFor() method
            %       function diag = getNegativeDiagnosticFor(constraint, actual)
            %           import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            %           import matlab.unittest.internal.diagnostics.DiagnosticSense;
            %           if constraint.satisfiedBy(actual)
            %               diag = ConstraintDiagnosticFactory.generateFailingDiagnostic( ...
            %                   constraint, ...
            %                   DiagnosticSense.Negative,
            %                   actual, ...  %optional
            %                   expected);   %optional
            %               ... make modifications to diag
            %               ... see help on matlab.unittest.diagnostics.ConstraintDiagnostic
            %           else
            %               ... see help on generatePassingDiagnostic()
            %           end
            %
            %   See also
            %       matlab.unittest.constraints.Constraint,
            %       matlab.unittest.constraints.Comparator,
            %       matlab.unittest.diagnostics.ConstraintDiagnostic,
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            diag = ConstraintDiagnosticFactory.createGenericDiagnostic(requirement, false, consType, varargin{:});
        end
    end
    
    methods (Static, Hidden)
        function diag = generateSizeMismatchDiagnostic(actVal, expVal)
            %generateSizeMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected sizes differ
            %   DIAG = generateSizeMismatchDiagnostic(ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic.
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            diag = ConstraintDiagnostic();
            diag.DisplayDescription = true;
            diag.DisplayActVal = true;
            diag.DisplayExpVal = true;
            
            diag.Description  = catalog.getString('SizeMismatch');
            diag.ActValHeader = catalog.getString('ActualSize');
            diag.ActVal = size(actVal);
            diag.ExpValHeader = catalog.getString('ExpectedSize');
            diag.ExpVal = size(expVal);
        end
        
        function diag = generateClassMismatchDiagnostic(actVal, expVal)
            %generateClassMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected classes differ
            %   DIAG = generateClassMismatchDiagnostic(ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic.
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            diag = ConstraintDiagnostic();
            diag.DisplayDescription = true;
            diag.DisplayActVal = true;
            diag.DisplayExpVal = true;
            
            diag.Description  = catalog.getString('ClassMismatch');
            diag.ActValHeader = catalog.getString('ActualClass');
            diag.ActVal = class(actVal);
            diag.ExpValHeader = catalog.getString('ExpectedClass');
            diag.ExpVal = class(expVal);
        end
        
        function diag = generateSparsityMismatchDiagnostic(actVal, expVal)
            %generateSparsityMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected sparsity differ
            %   DIAG = generateSparsityMismatchDiagnostic(ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic.
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            diag = ConstraintDiagnostic();
            diag.DisplayDescription = true;
            diag.DisplayActVal = true;
            diag.DisplayExpVal = true;
            
            if issparse(actVal)
                actSparsity = catalog.getString('SparseAttribute');
            else
                actSparsity = catalog.getString('FullAttribute');
            end
            if issparse(expVal)
                expSparsity = catalog.getString('SparseAttribute');
            else
                expSparsity = catalog.getString('FullAttribute');
            end
            
            diag.Description  = catalog.getString('SparsityMismatch');
            diag.ActValHeader = catalog.getString('ActualSparsity');
            diag.ActVal = actSparsity;
            diag.ExpValHeader = catalog.getString('ExpectedSparsity');
            diag.ExpVal = expSparsity;
        end
        
        function diag = generateComplexityMismatchDiagnostic(actVal, expVal)
            %generateComplexityMismatchDiagnostic   Generate a failing ConstraintDiagnostic when actual and expected complexity differ
            %   DIAG = generateComplexityMismatchDiagnostic(ACTVAL, EXPVAL)
            %   generates a failing ConstraintDiagnostic.
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            catalog = ConstraintDiagnosticFactory.MessageCatalog;
            
            diag = ConstraintDiagnostic();
            diag.DisplayDescription = true;
            diag.DisplayActVal = true;
            diag.DisplayExpVal = true;
            
            if isreal(actVal)
                actComplexity = catalog.getString('RealAttribute');
            else
                actComplexity = catalog.getString('ComplexAttribute');
            end
            if isreal(expVal)
                expComplexity = catalog.getString('RealAttribute');
            else
                expComplexity = catalog.getString('ComplexAttribute');
            end
            
            diag.Description  = catalog.getString('ComplexityMismatch');
            diag.ActValHeader = catalog.getString('ActualComplexity');
            diag.ActVal = actComplexity;
            diag.ExpValHeader = catalog.getString('ExpectedComplexity');
            diag.ExpVal = expComplexity;
        end
        
        function diag = generateFailureTableDiagnostic(failedIndices, actVal, expVal, varargin)
            % generateFailureTableDiagnostic   Generate a failure table
            %   diagnostic when actual and expected numeric values differ.
            
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            % Extract tolerance values and type if specified.
            tolTypes       = varargin(1:2:end-1);
            tolVals        = varargin(2:2:end);
            
            % Replicate tolerance value if scalar
            tolVals = cellfun(@(x)replicateTolerance(x, size(expVal)), tolVals, 'UniformOutput', false);
            
            % Create unique tolerance type strings in case they belong to
            % the same class
            tolTypes = matlab.lang.makeUniqueStrings(tolTypes);
            
            % Truncate failed indices at max limit
            [failedIndices, failureTableHeader] = truncateFailedIndices(failedIndices);
            
            % Construct failure table diagnostic
            diag = ConstraintDiagnosticFactory.constructFailureTableDiagnostic(failureTableHeader, failedIndices, actVal, expVal, tolTypes, tolVals);
        end
    end
end


function [failedIndices, failureTableHeader] = truncateFailedIndices(failedIndices)
% Truncate failed indices at a max limit. This limits the number of rows

import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;

catalog = ConstraintDiagnosticFactory.MessageCatalog;

maxFailureLimit  = 50;
numFailedIndices = numel(failedIndices);

if numFailedIndices > maxFailureLimit
    failedIndices = failedIndices(1:maxFailureLimit);
    failureTableHeader = catalog.getString('TruncatedFailureTableHeader', maxFailureLimit, numFailedIndices);
else
    failureTableHeader = catalog.getString('FailureTableHeader');
end
end


function table = addNonScalarColumns(table, failedIndices, value)

import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
catalog = ConstraintDiagnosticFactory.MessageCatalog;

% Add the index column for all non-scalar arrays
failedIndices = failedIndices(:);
table.(catalog.getString('FailureTableIndex'))  = failedIndices;

if ~isvector(value)
    % Add the subscripts column for 2-D/n-D matrices
    table = addSubscriptsColumn(table, failedIndices, value);
end
end


function table = addSubscriptsColumn(table, failedIndices, value)
import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
catalog = ConstraintDiagnosticFactory.MessageCatalog;

valueSize = size(value);
subs{ndims(value)} = [];
for idx = numel(failedIndices):-1:1
    [subs{:}] = ind2sub(valueSize, failedIndices(idx));
    subStr = sprintf('%d,', subs{:});
    allSubStrs{idx} = ['(' subStr(1:end-1) ')'];
end

table.(catalog.getString('FailureTableSubscripts')) = categorical(allSubStrs.');
end


function [varargout] = selectAndColumnize(indices, varargin)
% Select values at indices provided and columnize

varargout = cell(size(varargin));
for i = 1:length(varargin)
    varargout{i} = varargin{i}(indices);
    varargout{i} = varargout{i}(:);
end
end


function tolVal = replicateTolerance(tolVal, sz)
if isscalar(tolVal)
    tolVal = repmat(tolVal, sz);
end
end


function description = createConstraintDiagnosticDescription(requirement, isSatisfied, consType)
import matlab.unittest.internal.diagnostics.DiagnosticSense;
import matlab.unittest.internal.diagnostics.createClassNameForCommandWindow;
import matlab.unittest.internal.diagnostics.MessageString;

cmdWindowName = class(requirement);

if consType == DiagnosticSense.Negative
    if isSatisfied
        msgKey = 'NegatedRequirementCompletelySatisfied';
    else
        msgKey = 'NegatedRequirementNotCompletelySatisfied';
    end
else % consType == DiagnosticSense.Positive
    if isSatisfied
        msgKey = 'RequirementCompletelySatisfied';
    else
        msgKey = 'RequirementNotCompletelySatisfied';
    end
end

id = sprintf('MATLAB:unittest:ConstraintDiagnosticFactory:%s', msgKey);
description = MessageString(id, createClassNameForCommandWindow(cmdWindowName));
end

% LocalWords:  ISSATISFIED CONSTYPE ACTVAL EXPVAL Vals FAILEDINDICES TOLVAL
% LocalWords:  TOLTYPE lang Columnize columnize sz Strs

classdef NumericComparator < matlab.unittest.constraints.Comparator & ...
                             matlab.unittest.internal.mixin.WithinMixin
    % NumericComparator - Comparator for comparing MATLAB numeric data types.
    %
    %   The NumericComparator comparator supports any MATLAB numeric data type.
    %   A numeric comparator is satisfied if inputs are of the same class with
    %   equivalent size, complexity, and sparsity and the built-in isequaln
    %   returns true.
    %
    %   When a tolerance is supplied, NumericComparator first checks for
    %   equivalent class, size, and sparsity of the actual and expected
    %   values. If these checks fail, the comparator is not satisfied. If
    %   these checks pass and the isequaln or complexity check fails,
    %   NumericComparator delegates comparison to the supplied tolerance.
    %
    %   NumericComparator methods:
    %       NumericComparator - Class constructor
    %
    %   NumericComparator properties:
    %       Tolerance - A matlab.unittest.constraints.Tolerance object
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    methods
        function comparator = NumericComparator(varargin)
            % NumericComparator - Class constructor
            %
            %   NumericComparator creates a comparator for numeric data types.
            %
            %   NumericComparator('Within',TOLOBJ) creates a comparator for numeric
            %   data types using a specified tolerance.
            
            comparator = comparator.parse(varargin{:});
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = builtin('isnumeric',value) && ~builtin('isobject',value);
        end
        
        function bool = containerSatisfiedBy(comparator, actVal, expVal)
            bool = haveSameClass(actVal,expVal) && ...
                haveSameSize(actVal,expVal) && ...
                haveSameSparsity(actVal,expVal) && ...
                comparator.valueCheckPasses(actVal,expVal);
        end
        
        function conds = getContainerConditionsFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;

            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);

            elseif ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);

            elseif ~haveSameSparsity(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSparsityMismatchDiagnostic(actVal, expVal);

            elseif haveSameComplexityAndValue(actVal,expVal)
                conds = MessageDiagnostic('MATLAB:unittest:NumericComparator:Equaln');

            elseif ~comparator.toleranceIsSupportedBy(expVal)
                if ~haveSameComplexity(actVal,expVal)
                    conds = ConstraintDiagnosticFactory.generateComplexityMismatchDiagnostic(actVal, expVal);
                else
                    conds = MessageDiagnostic('MATLAB:unittest:NumericComparator:NotEqualn');
                    if ~isempty(comparator.Tolerance)
                        conds = [conds,MessageDiagnostic('MATLAB:unittest:NumericComparator:ToleranceNotUsed', class(expVal))];
                    end
                    conds = [conds,constructFailureTableDiagnostic(actVal, expVal)];
                end
                
            else
                
                mc = metaclass(comparator.Tolerance);
                if ~isempty(mc.MethodList.findobj('Name','getConstraintDiagnosticFor','Access','public'))
                    conds = comparator.Tolerance.getConstraintDiagnosticFor(actVal, expVal);
                else
                    conds = comparator.Tolerance.getDiagnosticFor(actVal, expVal);
                end
                
                if isa(conds, 'matlab.unittest.diagnostics.ConstraintDiagnostic')
                    conds.DisplayActVal = false;
                    conds.DisplayExpVal = false;
                end
                if ~comparator.Tolerance.satisfiedBy(actVal,expVal)
                    conds = [MessageDiagnostic('MATLAB:unittest:NumericComparator:NotEqualn'),conds];
                end
            end
        end

        function value = valueToDisplayInDiagnostic(comparator, value)
            maxNumelPerDimension = 10;
            %Because the failure diagnostic table already displays the
            %values, then for large arrays, we should shrink the display in
            %order to make the diagnostic more concise.
            if comparator.supportsContainer(value) && (~ismatrix(value) || ~all(size(value) <= maxNumelPerDimension))
                value = sprintf('%s %s', ...
                    strjoin(arrayfun(@(x) sprintf('%u',x),size(value),'UniformOutput',false),'x'), ...
                    class(value));
            end
        end
    end
    
    methods(Access=private)
        function bool = toleranceIsSupportedBy(comparator,value)
            tol = comparator.Tolerance;
            bool = ~isempty(tol) && tol.supports(value);
        end
        
        function bool = toleranceIsSatisfiedBy(comparator,actVal,expVal)
            bool = comparator.toleranceIsSupportedBy(expVal) && ...
                comparator.Tolerance.satisfiedBy(actVal, expVal);
        end
        
        function bool = valueCheckPasses(comparator,actVal,expVal)
            bool = haveSameComplexityAndValue(actVal,expVal) || ...
                comparator.toleranceIsSatisfiedBy(actVal,expVal);
        end
    end
end


function bool = haveSameClass(actVal,expVal)
bool = strcmp(class(actVal), class(expVal));
end


function bool = haveSameSize(actVal,expVal)
bool = isequal(size(actVal), size(expVal));
end


function bool = haveSameSparsity(actVal,expVal)
bool = (issparse(actVal) == issparse(expVal));
end


function bool = haveSameComplexity(actVal,expVal)
bool = isreal(actVal) == isreal(expVal);
end


function bool = haveSameComplexityAndValue(actVal,expVal)
bool =  haveSameComplexity(actVal,expVal) && isequaln(expVal,actVal);
end


function diag = constructFailureTableDiagnostic(actVal, expVal)
import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
failedIndices = getFailedIndices(actVal, expVal);
diag = ConstraintDiagnosticFactory.generateFailureTableDiagnostic(...
    failedIndices, actVal, expVal);
end


function failedIndices = getFailedIndices(actVal, expVal)
% getFailedIndices - Helper function to find failure indices. This function
% assumes that the actual and expected values have the same sparsity.
if issparse(expVal)
    nzIdx = union(find(actVal),find(expVal));
    mask = ~arrayfun(@isequaln, full(actVal(nzIdx)), full(expVal(nzIdx)));
    failedIndices = nzIdx(mask);
else
    failedIndices = find(~arrayfun(@isequaln, actVal, expVal));
end
end
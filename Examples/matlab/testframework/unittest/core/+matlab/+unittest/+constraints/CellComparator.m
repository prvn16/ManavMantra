classdef CellComparator < matlab.unittest.internal.constraints.ContainerComparator
    % CellComparator - Comparator for comparing MATLAB cell arrays
    %
    %   The CellComparator natively supports cell arrays and performs a
    %   comparison by iterating over each element of the cell array and
    %   recursing if necessary. By default, a cell comparator only supports
    %   empty cell arrays. However, it can support other data types during
    %   recursion by passing a comparator to the constructor.
    %
    %   CellComparator methods:
    %       CellComparator - Class constructor
    %
    %   CellComparator properties:
    %       Recursive - Boolean indicating whether the instance operates recursively
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    
    % Copyright 2010-2016 The MathWorks, Inc.
    
    methods
        function comparator = CellComparator(varargin)
            % CellComparator - Class constructor
            %
            %   CellComparator creates a comparator for cell arrays.
            %
            %   CellComparator(COMPOBJ) creates a comparator for cell arrays and
            %   indicates a comparator, COMPOBJ, that defines the comparator used to
            %   compare values contained in the cell array.
            %
            %   CellComparator(...,'Recursively', true) creates a comparator for cell
            %   arrays and indicates that the comparator can be reused recursively to
            %   compare values contained in the cell array.
            
            comparator = comparator@...
                matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
        end
    end

    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = builtin('iscell',value);
        end
        
        function bool = containerSatisfiedBy(~,actVal,expVal)
            bool = haveSameClass(actVal,expVal) && ...
                haveSameSize(actVal,expVal);
        end
        
        function conds = getContainerConditionsFor(~, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.diagnostics.Diagnostic;
            
            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            else
                conds = Diagnostic.empty(1,0);
            end
        end
        
        function subComparisons = getElementComparisons(comparator,comparison)
            import matlab.unittest.constraints.Comparison;
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            comparators = comparator.getComparatorsForElements(comparison);
            
            args = {actVal,expVal,{comparators}};
            if comparison.IsUsingValueReference
                args{end+1} = generateSubReferenceCell(expVal,comparison.ValueReference);
            end
            subComparisons = Comparison.fromCellArrays(args{:});
        end
    end
end


function bool = haveSameClass(actVal,expVal)
bool = strcmp(class(actVal), class(expVal));
end


function bool = haveSameSize(actVal,expVal)
bool = isequal(size(actVal), size(expVal));
end


function subReferenceCell = generateSubReferenceCell(value,valueReference)
indToRef = @(ind) sprintf('%s{%u}',valueReference,ind);
subReferenceCell = arrayfun(indToRef,1:numel(value),'UniformOutput',false);
end
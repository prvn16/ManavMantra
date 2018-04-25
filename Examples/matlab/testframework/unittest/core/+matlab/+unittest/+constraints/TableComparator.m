classdef TableComparator < matlab.unittest.internal.constraints.ContainerComparator
    % TableComparator - Comparator for comparing tables
    %
    %   The TableComparator compares tables by iterating over each column. By
    %   default, a TableComparator only supports empty tables. To compare
    %   column values of non-empty tables, pass another comparator to the
    %   TableComparator constructor.
    %
    %   When IsEqualTo uses TableComparator to compare table instances, the
    %   IsEqualTo properties, like IgnoreCase and Tolerance, are applied to the
    %   comparison of columns. However, the IsEqualTo properties are not
    %   applied to the comparison of table metadata properties.
    %
    %   TableComparator methods:
    %       TableComparator - Class constructor
    %
    %   TableComparator properties:
    %       Recursive - Boolean indicating whether the instance operates recursively
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function comparator = TableComparator(varargin)
            % TableComparator - Class constructor
            %
            %   TableComparator creates a comparator for tables.
            %
            %   TableComparator(COMPOBJ) creates a comparator for tables with a
            %   specified comparator, COMPOBJ, to compare values in the columns.
            %
            %   TableComparator(...,'Recursively', true) creates a comparator for
            %   tables that can be used recursively to compare values contained in the
            %   columns.
            comparator = comparator@...
                matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
        end
    end

    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = isa(value,'table');
        end
        
        function bool = containerSatisfiedBy(~,actVal,expVal)
            import matlab.unittest.constraints.IsEqualTo;
            bool = haveSameClass(actVal,expVal) && ...
                haveSameSize(actVal,expVal) && ...
                IsEqualTo.DefaultComparator.satisfiedBy(actVal.Properties,expVal.Properties);
        end
        
        function conds = getContainerConditionsFor(~, actVal, expVal)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            elseif ~IsEqualTo.DefaultComparator.satisfiedBy(actVal.Properties,expVal.Properties)
                conds = IsEqualTo.DefaultComparator.getDiagnosticFor(...
                    actVal.Properties,expVal.Properties,'<table>.Properties');
                conds.ValueReferenceHeader = sprintf('%s\n%s',...
                    getString(message('MATLAB:unittest:TableComparator:TablePropertiesDoNotMatch')),...
                    conds.ValueReferenceHeader);
                conds.DisplayActVal = false;
                conds.DisplayExpVal = false;
            else
                conds = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
            end
        end
        
        function conds = getCasualContainerConditionsFor(~, actVal, expVal)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            elseif ~IsEqualTo.DefaultComparator.satisfiedBy(actVal.Properties,expVal.Properties)
                conds = IsEqualTo.DefaultComparator.getCasualDiagnosticFor(...
                    actVal.Properties,expVal.Properties,'<table>.Properties');
                conds.ValueReferenceHeader = sprintf('%s\n%s',...
                    getString(message('MATLAB:unittest:TableComparator:TablePropertiesDoNotMatch')),...
                    conds.ValueReferenceHeader);
            else
                conds = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
            end
        end
        
        function subComparisons = getElementComparisons(comparator,comparison)
            import matlab.unittest.constraints.Comparison;
            
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            if isempty(expVal) % Avoid returning columns with zero rows, like table.empty(0,3)
                subComparisons = comparator.EmptyComparisonArray;
                return;
            end
            comparators = comparator.getComparatorsForElements(comparison);
            
            variableNames = expVal.Properties.VariableNames;
            actElemsCell = cellfun(@(x) actVal.(x),variableNames,'UniformOutput',false);
            expElemsCell = cellfun(@(x) expVal.(x),variableNames,'UniformOutput',false);
            
            args = {actElemsCell,expElemsCell,{comparators}};
            if comparison.IsUsingValueReference
                varNameToRef = @(varName) sprintf('%s.%s',comparison.ValueReference,varName);
                args{end+1} = cellfun(varNameToRef,variableNames,'UniformOutput',false);
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
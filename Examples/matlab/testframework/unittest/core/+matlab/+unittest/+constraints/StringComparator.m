classdef StringComparator < matlab.unittest.constraints.Comparator & ...
                            matlab.unittest.internal.mixin.IgnoringCaseMixin & ...
                            matlab.unittest.internal.mixin.IgnoringWhitespaceMixin
    % StringComparator - Comparator for comparing strings, character arrays, and cell arrays of character arrays
    %
    %   The StringComparator comparator supports strings, character arrays,
    %   and cell arrays of character arrays. By default, StringComparator
    %   checks that the values have equal size and class and then performs a
    %   case-sensitive comparison on each value.
    %
    %   StringComparator methods:
    %       StringComparator - Class constructor
    %
    %   StringComparator properties:
    %       IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %       IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %
    %    See also:
    %       matlab.unittest.constraints.Comparator
    %       matlab.unittest.constraints.IsEqualTo
    %       string
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function comparator = StringComparator(varargin)
            % StringComparator - Class constructor
            %
            %   StringComparator creates a comparator for strings, character arrays,
            %   and cell arrays of character arrays.
            %
            %   StringComparator(..., 'IgnoringCase', true) creates a comparator for
            %   strings, character arrays, and cell arrays of character arrays that
            %   ignores case differences.
            %
            %   StringComparator(..., 'IgnoringWhitespace', true) creates a comparator
            %   for strings, character vectors, and cell arrays of character vectors
            %   that ignores whitespace differences.
            
            comparator = comparator.parse(varargin{:});
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = builtin('ischar',value) || ...
                builtin('isstring',value) || ...
                (builtin('iscellstr',value) && ~isempty(value));
        end
        
        function bool = containerSatisfiedBy(comparator, actVal, expVal)
            if builtin('ischar',expVal)
                bool = builtin('ischar',actVal) && ...
                    comparator.charsAreEquivalent(actVal,expVal);
            elseif builtin('isstring',expVal)
                bool = builtin('isstring',actVal) && ...
                    comparator.stringsHaveSameStructure(actVal,expVal);
            else % iscellstr
                bool = builtin('iscell',actVal) && haveSameSize(actVal,expVal);
                % getElementComparisons will handle "non-cellstr cell" case
            end
        end
        
        function elemComparisons = getElementComparisons(comparator,comparison)
            expVal = comparison.ExpectedValue;
            
            if builtin('ischar',expVal)
                elemComparisons = comparator.EmptyComparisonArray;
            elseif builtin('isstring',expVal)
                elemComparisons = comparator.getStringElementComparisons(comparison);
            else % iscellstr
                elemComparisons = comparator.getCellElementComparisons(comparison);
            end
        end
        
        function conds = getContainerConditionsFor(comparator, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if ~haveSameClass(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif builtin('ischar',expVal)
                conds = comparator.getCharConditionsFor(actVal,expVal);
            elseif builtin('isstring',expVal)
                conds = comparator.getStringConditionsFor(actVal,expVal);
            else %iscellstr
                conds = comparator.getCellConditionsFor(actVal,expVal);
            end
        end
    end
    
    methods (Access=private)
        function bool = charsAreEquivalent(comparator,actVal,expVal)
            bool = isequal(actVal,expVal) || ...
                (comparator.textValuesAreEqual(actVal,expVal) && ...
                comparator.charSizeValidationPasses(actVal,expVal));
        end
        
        function bool = charSizeValidationPasses(comparator, actVal, expVal)
            bool = comparator.IgnoreWhitespace || ...
                haveSameSize(actVal,expVal);
        end
        
        function bool = stringsHaveSameStructure(comparator,actVal,expVal)
            if ~haveSameSize(actVal,expVal)
                bool = false;
            elseif isscalar(expVal)
                bool = comparator.scalarStringsAreEqual(actVal, expVal);
            else
                %The  nonscalar cases is handled in getElementComparisons
                bool = true;
            end
        end
        
        function bool = scalarStringsAreEqual(comparator,actVal,expVal)
            bool = isequaln(actVal, expVal) || ...
                comparator.textValuesAreEqual(actVal,expVal);
        end
        
        function [bool,mask] = textValuesAreEqual(comparator, actVal, expVal)
            if comparator.IgnoreWhitespace
                actVal = comparator.removeWhitespaceFrom(actVal);
                expVal = comparator.removeWhitespaceFrom(expVal);
            end
            if comparator.IgnoreCase
                mask = strcmpi(actVal, expVal);
            else
                mask = strcmp(actVal, expVal);
            end
            bool = all(mask(:));
        end
        
        function elemComparisons = getStringElementComparisons(comparator,comparison)
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            
            if isscalar(expVal) || isequaln(actVal, expVal)
                elemComparisons = comparator.EmptyComparisonArray;
                return;
            end
            
            matchingMissing = ismissing(actVal) & ismissing(expVal);
            actVal(matchingMissing) = "";
            expVal(matchingMissing) = "";
            
            [textArraysAreEqual,mask] = comparator.textValuesAreEqual(actVal, expVal);
            
            if textArraysAreEqual
                elemComparisons = comparator.EmptyComparisonArray;
            else
                firstBadInd = find(~mask,1);
                elemComparisons = comparator.createStringElementComparison(firstBadInd,comparison);
            end
        end
        
        function elemComparison = createStringElementComparison(comparator,index,comparison)
            actElement = comparison.ActualValue(index);
            expElement = comparison.ExpectedValue(index);
            args = {actElement,expElement,comparator};
            if comparison.IsUsingValueReference
                args{end+1} = sprintf('%s(%u)',comparison.ValueReference,index);
            end
            elemComparison = matlab.unittest.constraints.Comparison(args{:});
        end
        
        function elemComparisons = getCellElementComparisons(comparator,comparison)
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            
            if isequaln(actVal, expVal)
                elemComparisons = comparator.EmptyComparisonArray;
                return;
            end
            
            if ~builtin('iscellstr',actVal)
                firstBadInd = find(cellfun(@(x) ~builtin('ischar',x),actVal),1);
                elemComparisons = comparator.createCellElementComparison(firstBadInd,comparison);
                return;
            end
            
            [textArraysAreEqual,mask] = comparator.textValuesAreEqual(actVal, expVal);
            
            if textArraysAreEqual && ~comparator.IgnoreWhitespace
                mask = cellfun(@(actElem,expElem) haveSameSize(actElem,expElem),actVal,expVal);
                textArraysAreEqual = all(mask(:));
            end
            
            if textArraysAreEqual
                elemComparisons = comparator.EmptyComparisonArray;
            else
                firstBadInd = find(~mask,1);
                elemComparisons = comparator.createCellElementComparison(firstBadInd,comparison);
            end
        end
        
        function elemComparison = createCellElementComparison(comparator,index,comparison)
            actElement = comparison.ActualValue{index};
            expElement = comparison.ExpectedValue{index};
            args = {actElement,expElement,comparator};
            if comparison.IsUsingValueReference
                args{end+1} = sprintf('%s{%u}',comparison.ValueReference,index);
            end
            elemComparison = matlab.unittest.constraints.Comparison(args{:});
        end
        
        function conds = getCharConditionsFor(comparator,actVal,expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            if ~comparator.textValuesAreEqual(actVal,expVal)
                conds = comparator.textValuesComparisonCondition('CharsNotEqual');
            elseif ~comparator.charSizeValidationPasses(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal,expVal);
            else
                conds = comparator.textValuesComparisonCondition('CharsEqual');
            end
        end
        
        function conds = getStringConditionsFor(comparator,actVal,expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            if ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal,expVal);
            elseif ~isscalar(expVal) || comparator.scalarStringsAreEqual(actVal, expVal)
                conds = comparator.textValuesComparisonCondition('StringsEqual');
            else
                conds = comparator.textValuesComparisonCondition('StringsNotEqual');
            end
        end
        
        function conds = getCellConditionsFor(comparator,actVal,expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            if ~haveSameSize(actVal,expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal,expVal);
            else
                conds = comparator.textValuesComparisonCondition('CellstrsEqual');
            end
        end
        
        function cond = textValuesComparisonCondition(comparator,caseStr)
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            if comparator.IgnoreWhitespace && comparator.IgnoreCase
                cond = MessageDiagnostic(['MATLAB:unittest:StringComparator:' caseStr 'IgnoringCaseAndWhitespace']);
            elseif comparator.IgnoreWhitespace
                cond = MessageDiagnostic(['MATLAB:unittest:StringComparator:' caseStr 'IgnoringWhitespace']);
            elseif comparator.IgnoreCase
                cond = MessageDiagnostic(['MATLAB:unittest:StringComparator:' caseStr 'IgnoringCase']);
            else
                cond = MessageDiagnostic(['MATLAB:unittest:StringComparator:' caseStr]);
            end
        end
    end
end

function bool = haveSameSize(actVal,expVal)
bool = isequal(size(actVal), size(expVal));
end

function bool = haveSameClass(actVal,expVal)
bool = isequal(class(actVal), class(expVal));
end

% LocalWords:  unittest isstring Cellstrs

classdef(Hidden) Comparison < handle
    % Comparison - Holds values and Comparators used to perform a comparison.
    %
    %   Comparison properties:
    %       ActualValue    - The actual value of the comparison
    %       ExpectedValue  - The expected value of the comparison
    %       Comparators    - A matlab.unittest.constraints.Comparator object array
    %       ValueReference - String indicating how ExpectedValue can be referenced
    %
    %   Comparison methods:
    %      Comparison - Class constructor.
    %
    % Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=private)
        % ActualValue - The actual value of the comparison
        %
        %   The ActualValue property must be specified during construction
        %   of the Comparison instance as the first input argument.
        ActualValue = [];
        
        % ExpectedValue - The expected value of the comparison
        %
        %   The ExpectedValue property must be specified during construction
        %   of the Comparison instance as the second input argument.
        ExpectedValue = [];
        
        % Comparators - A matlab.unittest.constraints.Comparator object array
        %
        %   The Comparators array is used to compare ActualValue against
        %   ExpectedValue.
        %
        %   The Comparators property must be specified during construction
        %   of the Comparison instance as the third input argument.
        Comparators = matlab.unittest.constraints.Comparator.empty(1,0);
        
        % ValueReference - String indicating how ExpectedValue is referenced
        %
        %   When comparing large data structures, the ValueReference helps
        %   to reference the ExpectedValue in the data structure. For
        %   example if a Comparison object A existed with A.ActualValue and
        %   A.ExpectedValue both containing cell arrays, then a Comparison
        %   object B to compare the second element of each cell array could
        %   be constructed with B.ActualValue equal to A.ActualValue{2},
        %   B.ExpectedValue equal to A.ExpectedValue{2}, and
        %   B.ValueReference equal to sprintf('%s{2}',A.ValueReference).
        %
        %   The ValueReference property must be specified during construction
        %   of the Comparison instance as the fourth input argument.
        ValueReference = '';
    end
    
    properties(Hidden, SetAccess=private)
        IsUsingValueReference = false;
    end
    
    properties(Dependent, Hidden, SetAccess=private)
        SupportedComparatorIndex
    end
    
    properties(Access=private)
        InternalSupportedComparatorIndex = [];
    end
    
    methods
        function comparison = Comparison(actVal,expVal,comparators,reference)
            %Comparison - Class constructor.
            %
            %  Comparison(actVal,expVal,comparators,valueReference) creates
            %  a matlab.unittest.internal.Comparison instance with
            %  ActualValue equal to actVal, ExpectedValue equal to expVal,
            %  Comparators equal to comparators, and ValueReference equal
            %  to valueReference.
            if nargin == 0
                return;
            end
            comparison.ActualValue = actVal;
            comparison.ExpectedValue = expVal;
            comparison.Comparators = comparators;
            if nargin > 3
                comparison.IsUsingValueReference = true;
                comparison.ValueReference = reference;
            end
        end
        
        function index = get.SupportedComparatorIndex(comparison)
            index = comparison.InternalSupportedComparatorIndex;
            if isempty(index)
                index = comparison.Comparators.findFirstComparatorFor(comparison.ExpectedValue);
                comparison.InternalSupportedComparatorIndex = index;
            end
        end
    end
    
    methods(Static)
        function comparisonArray = fromCellArrays(actValCell,expValCell,comparatorsCell,referenceCell)
            import matlab.unittest.constraints.Comparison;
            
            % Note that this algorithm needs to be fast since it is heavily
            % used. This current algorithm is faster than using "deal".
            numOfElements = numel(actValCell);
            if numOfElements == 0
                comparisonArray = Comparison.empty(1,0);
                return;
            end
            
            numOfComparatorArrays = numel(comparatorsCell);
            comparisonArray(numOfElements) = Comparison();
            for k=1:numOfElements
                comparisonArray(k).ActualValue = actValCell{k};
                comparisonArray(k).ExpectedValue = expValCell{k};
                comparisonArray(k).Comparators = comparatorsCell{min(k,numOfComparatorArrays)};
            end
            
            if nargin > 3
                for k=1:numOfElements
                    comparisonArray(k).IsUsingValueReference = true;
                    comparisonArray(k).ValueReference = referenceCell{k};
                end
            end
        end
    end
end
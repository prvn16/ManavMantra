classdef (Hidden) ContainerComparator < matlab.unittest.constraints.Comparator & ...
                          matlab.unittest.internal.mixin.NameValueForwarderMixin & ...
                          matlab.unittest.internal.mixin.IncludingSelfMixin & ...
                          matlab.unittest.internal.mixin.IncludingSiblingsMixin
    % This class is undocumented.
                      
    %  Copyright 2010-2016 The MathWorks, Inc.
    properties(Constant, Access=private)
        EmptyComparatorArray = matlab.unittest.constraints.Comparator.empty(1,0);
    end
    
    properties(Hidden, SetAccess=private)
        UserProvidedComparator = matlab.unittest.internal.constraints.ContainerComparator.EmptyComparatorArray;
    end
    
    methods(Access=protected, Sealed)
        function comparator = ContainerComparator(varargin)
            import matlab.unittest.constraints.Comparator;
            if ~isempty(varargin) && isa(varargin{1}, 'Comparator')
                comparator.UserProvidedComparator = reshape(varargin{1},1,[]);
                args = varargin(2:end);
            else
                args = varargin;
            end
            comparator = comparator.parse(args{:});
        end
        
        function comparators = getComparatorsForElements(comparator,comparison)
            innerComps = comparator.UserProvidedComparator;
            includeSelf = comparator.IncludeSelf;
            includeSiblings = comparator.IncludeSiblings;
            
            if includeSelf && includeSiblings
                updatedSelfAndSiblings = comparator.getUpdatedSelfAndSiblingsFrom(comparison);
                comparators = [updatedSelfAndSiblings,innerComps];
            elseif includeSelf
                updatedSelf = comparator.getUpdatedSelf();
                comparators = [updatedSelf,innerComps];
            elseif includeSiblings
                siblings = comparator.getSiblingsFrom(comparison);
                comparators = [siblings,innerComps];
            else
                comparators = innerComps;
            end
        end
    end
    
    methods(Access = protected)
        function bool = isStateful(~)
            bool = false;
        end
    end
      
    methods(Hidden, Access = protected)
        function comparator = forwardNameValue(comparator,paramName, paramValue)
            comparators = comparator.UserProvidedComparator;
            for k=1:numel(comparators)
                comparators(k) = comparator.applyNameValueTo(...
                    comparators(k), paramName, paramValue);
            end
            comparator.UserProvidedComparator = comparators;
        end
    end
    
    methods(Access=private)
        function siblings = getSiblingsFrom(~,comparison)
            selfIndex = comparison.SupportedComparatorIndex;
            siblings = comparison.Comparators([1:selfIndex-1,selfIndex+1:end]);
        end
        
        function comparator = getUpdatedSelf(comparator)
            if ~isempty(comparator.UserProvidedComparator)
                comparator.UserProvidedComparator = ...
                    matlab.unittest.internal.constraints.ContainerComparator.EmptyComparatorArray;
                comparator = comparator.includingSiblings();
            end
        end
        
        function updatedSelfAndSiblings = getUpdatedSelfAndSiblingsFrom(comparator,comparison)
            updatedSelfAndSiblings = comparison.Comparators;
            selfIndex = comparison.SupportedComparatorIndex;
            
            if ~isempty(comparator.UserProvidedComparator)
                comparator.UserProvidedComparator = ...
                    matlab.unittest.internal.constraints.ContainerComparator.EmptyComparatorArray;
                updatedSelfAndSiblings(selfIndex) = comparator;
            elseif comparator.isStateful()
                updatedSelfAndSiblings(selfIndex) = comparator;
            end
        end
    end
end
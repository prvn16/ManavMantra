classdef (Hidden) Comparator < matlab.mixin.Heterogeneous
    % This class is undocumented and may change in the future.
    
    % Comparator - Abstract interface for comparators
    %
    %   Comparators define a notion of equality for a set of data types and can
    %   be plugged in to the IsEqualTo constraint.
    %
    %   Classes which derive from the Comparator interface must provide a
    %   supportsContainer method and a containerSatisfiedBy method. If the
    %   values being compared are not containers containing elements, then
    %   these methods are to be implemented to determine full support and
    %   satisfaction of the values. Otherwise if the values being compared are
    %   containers containing elements, then these methods should only
    %   determine support and satisfaction of the containers themselves and the
    %   getElementComparisons method should be overridden in order to delegate
    %   the work of comparing each of the values' elements to other
    %   comparators.
    %
    %   By default, the diagnostic given by getDiagnosticFor will contain
    %   information on whether the comparator passed or failed and also include
    %   the actual and expected values supplied to the comparator. Subclasses
    %   may add conditions to the default diagnostic by overriding the
    %   getContainerConditionsFor method or instead may take more control over
    %   the diagnostic by overriding the getContainerDiagnosticFor method.
    %
    %   Comparator methods:
    %       supports                  - Returns a boolean value indicating whether the comparator supports a specified value
    %       satisfiedBy               - Returns a boolean value indicating whether the comparator was satisfied by two values
    %       getDiagnosticFor          - Returns a diagnostic object containing information about the result of a comparison
    %       supportsContainer         - Returns a boolean value indicating whether the comparator supports a specified value's container
    %       containerSatisfiedBy      - Returns a boolean value indicating whether the comparator was satisfied by the two values' containers
    %       getContainerConditionsFor - Returns a diagnostic array to be added as conditions to the default output of getContainerDiagnosticFor
    %       getContainerDiagnosticFor - Returns a diagnostic object containing information about the result of a container comparison
    %       getElementComparisons     - Returns a matlab.unittest.constraints.Comparison array associated with the elements to be compared
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    %       matlab.unittest.diagnostics.ComparatorDiagnostic
    
    %  Copyright 2010-2017 The MathWorks, Inc.

    properties(Constant, Hidden, Access=protected)
        EmptyComparisonArray = matlab.unittest.constraints.Comparison.empty(1,0);
        EmptyDiagnosticArray = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
    end
    
    methods(Hidden, Sealed)
        function bool = supports(comparators,value)
            % supports - Returns a boolean value indicating whether the comparator supports a specified value
            %
            %   Examples:
            %      comp = CellComparator;
            %      comp.supports(3) % returns false
            %      comp.supports({}) % returns true
            %      comp.supports({3}) % returns false
            %
            %      comp = CellComparator(NumericComparator);
            %      comp.supports(3) % returns false
            %      comp.supports({}) % returns true
            %      comp.supports({3}) % returns true
            %
            %      comp = [NumericComparator,CellComparator];
            %      comp.supports(3) % returns true
            %      comp.supports({}) % returns true
            %      comp.supports({3}) % returns false
            import matlab.unittest.constraints.Comparison;
            comparison = Comparison(value,value,comparators);
            bool = deepComparisonIsSupported(comparison);
        end
        
        function bool = satisfiedBy(comparators,actVal,expVal)
            % satisfiedBy - Returns a boolean value indicating whether the comparator was satisfied by two values
            %
            %   Examples:
            %      comp = CellComparator(StringComparator);
            %      comp.satisfiedBy({'a','b'},{'a','c'}) % returns false
            %
            %      comp = [NumericComparator,CellComparator];
            %      comp.satisfiedBy(3,3) % returns true
            %      comp.satisfiedBy(cell(0,2),cell(0,1)) % returns false
            import matlab.unittest.constraints.Comparison;
            comparison = Comparison(actVal,expVal,comparators);
            bool = deepComparisonIsSatisfied(comparison);
        end
        
        function diag = getDiagnosticFor(comparators, actVal, expVal, valueReference)
            % getDiagnosticFor - Returns a diagnostic object containing information about the result of a comparison
            %
            %   Examples:
            %      comp = NumericComparator;
            %      diag = comp.getDiagnosticFor(3,3) % returns a passing ComparatorDiagnostic
            %
            %      comp = CellComparator(StringComparator);
            %      diag = comp.getDiagnosticFor({'a','b'},{'a','c'})  % returns a failing ComparatorDiagnostic
            import matlab.unittest.constraints.Comparison;
            import matlab.unittest.diagnostics.ComparatorDiagnostic;
            topLevelReference = getString(message('MATLAB:unittest:Comparator:ValueHolder'));
            if nargin < 4
                valueReference = topLevelReference;
            end
            
            comparison = Comparison(actVal,expVal,comparators,valueReference);
            
            [elemDiag,elemPassed,elemComparison] = getDiagnosticParts(...
                @getContainerDiagnosticFor,comparison,0);
            
            isTopLevel = strcmp(elemComparison.ValueReference,topLevelReference);
            
            diag = ComparatorDiagnostic('Passed',elemPassed,...
                'ValueReference',elemComparison.ValueReference,...
                'DisplayValueReference',~isTopLevel,...
                'ActVal',actVal,...
                'ExpVal',expVal,...
                'ConditionsList',elemDiag);
            
            if isTopLevel
                diag.DisplayActVal = false;
                diag.DisplayExpVal = false;
            end
        end
    end

    methods(Abstract, Hidden, Access=protected)
        % supportsContainer - Returns a boolean value indicating whether the comparator supports a specified value's container
        %
        %   For example, CellComparator's supports method would return true for any
        %   cell array regardless of the types of elements it contains.
        %
        %   Note that supports uses getElementComparisons in addition to
        %   supportsContainer to help determine support of the entire value (i.e.
        %   the container and its elements).
        bool = supportsContainer(comparator, value);
        
        
        % containerSatisfiedBy - Returns a boolean value indicating whether the comparator was satisfied by the two values' containers
        %
        %   For example, if expVal={0,0} then CellComparator's containerSatisfiedBy
        %   method would return true when actVal={1,2} since the class and size are
        %   the same, and return false when actVal=[0,0] or actVal ={0} due to size
        %   or class mismatch.
        %
        %   Note that satisfiedBy uses getElementComparisons in addition to
        %   containerSatisfiedBy to help determine satisfaction of the entire
        %   values (i.e. the containers and their elements).
        bool = containerSatisfiedBy(comparator, actVal, expVal);
    end
    
    methods(Hidden, Access=protected)
        function comp = Comparator()
        end
        
        function conds = getContainerConditionsFor(comparator, actVal, expVal) %#ok<INUSD>
            % getContainerConditionsFor - Returns a diagnostic array to be added as conditions to the default output of getContainerDiagnosticFor
            %
            %   By default, if not overridden, getContainerConditionsFor returns an
            %   empty matlab.unittest.diagnostics.Diagnostic array.
            %
            %   Otherwise, getContainerConditionsFor should return an array of
            %   matlab.unittest.diagnostics.Diagnostic objects which give more
            %   information regarding the comparison of the actual value's container
            %   verses the expected value's container. If getContainerDiagnosticFor is
            %   not overridden, then this Diagnostic array will be added as conditions
            %   to the default diagnostic given by getContainerDiagnosticFor.
            conds = comparator.EmptyDiagnosticArray;
        end
        
        function diag = getContainerDiagnosticFor(comparator, actVal, expVal)
            % getContainerDiagnosticFor - Returns a diagnostic object containing information about the result of a container comparison
            %
            %   By default, if not overridden, getContainerDiagnosticFor returns a
            %   matlab.unittest.diagnostics.Diagnostic object containing information on
            %   whether the comparator's containerSatisfiedBy method passed or failed
            %   and also includes the actual and expected values supplied to the
            %   comparator. Any conditions returned by getContainerConditionsFor are
            %   also displayed.
            %
            %   Otherwise, getContainerDiagnosticFor should return a
            %   matlab.unittest.diagnostic.Diagnostic object containing information
            %   regarding the result of containerSatisfiedBy.
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if comparator.containerSatisfiedBy(actVal,expVal)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    comparator, DiagnosticSense.Positive, actVal, expVal);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    comparator, DiagnosticSense.Positive, actVal, expVal);
            end
            
            %These lines are required due to Comparators like NumericComparator
            %wanting to modify the display of its ActVal and ExpVal:
            diag.ActVal = comparator.valueToDisplayInDiagnostic(actVal);
            diag.ExpVal = comparator.valueToDisplayInDiagnostic(expVal);
            
            conds = comparator.getContainerConditionsFor(actVal, expVal);
            validateFunctionGaveDiagnosticOutput(@getContainerConditionsFor,{comparator,actVal,expVal},conds);
            diag.ConditionsList = conds;
        end
        
        function subComparisons = getElementComparisons(comparator,comparison) %#ok<INUSD>
            % getElementComparisons - Returns a matlab.unittest.constraints.Comparison array associated with the elements to be compared
            %
            %   By default, if not overridden, getElementComparisons returns an empty
            %   matlab.unittest.constraints.Comparison array.
            %
            %   Otherwise, getElementComparisons should use the current
            %   matlab.unittest.constraints.Comparison object input which is associated
            %   with the containers themselves and return a
            %   matlab.unittest.constraint.Comparison array associated with the
            %   containers' elements.
            %
            %   For example, when constructing a comparator for an object which
            %   contains a NumberValue and a StringValue property, the work to compare
            %   these properties could be delegated by overriding the
            %   getElementComparisons method in this way:
            %     function elementComparisons = getElementComparisons(comparator,comparison)
            %         import matlab.unittest.constraints.Comparison;
            %         import matlab.unittest.NumericComparator;
            %         import matlab.unittest.StringComparator;
            %         actualObject = comparison.ActualValue;
            %         expectedObject = comparison.ExpectedValue;
            %         objectReference = comparison.ValueReference;
            %         elementComparisons = [...
            %             Comparison(...
            %                 actualObject.NumberValue,...
            %                 expectedObject.NumberValue,...
            %                 NumericComparator(),...
            %                 sprintf('%s.NumberValue',objectReference)),...
            %             Comparison(...
            %                 actualObject.StringValue,...
            %                 expectedObject.StringValue,...
            %                 StringComparator(),...
            %                 sprintf('%s.StringValue',objectReference'))];
            %     end
            subComparisons = comparator.EmptyComparisonArray;
        end
        
        function conds = getCasualContainerConditionsFor(comparator, actVal, expVal)
            conds = comparator.getContainerConditionsFor(actVal, expVal);
            validateFunctionGaveDiagnosticOutput(@getContainerConditionsFor,{comparator,actVal,expVal},conds);
            conds = matlab.unittest.internal.diagnostics.convertToCasualConditions(conds);
        end
        
        function value = valueToDisplayInDiagnostic(~, value)
            %This method is required due to Comparators like NumericComparator
            %wanting to modify the display of its ActVal and ExpVal.
        end
    end
    
    methods(Hidden, Sealed)
        function index = findFirstComparatorFor(comparators,value)
            for index=1:numel(comparators)
                comparator = comparators(index);
                if comparator.supportsContainer(value)
                    return;
                end
            end
            index = [];
        end
        
        function diag = getCasualDiagnosticFor(comparator, actVal, expVal, valueReference)
            import matlab.unittest.constraints.Comparison;
            import matlab.unittest.diagnostics.ComparatorDiagnostic;
            topLevelReference = getString(message('MATLAB:unittest:Comparator:ValueHolder'));
            if nargin < 4
                valueReference = topLevelReference;
            end
            
            comparison = Comparison(actVal,expVal,comparator,valueReference);
            
            [elemConds,elemPassed,elemComparison] = getDiagnosticParts(...
                @getCasualContainerConditionsFor,comparison,0);
            
            isTopLevel = strcmp(elemComparison.ValueReference,topLevelReference);
            
            diag = ComparatorDiagnostic('Passed',elemPassed,...
                'ValueReference',elemComparison.ValueReference,...
                'DisplayValueReference',~isTopLevel,...
                'ActVal',elemComparison.ActualValue,...
                'ExpVal',elemComparison.ExpectedValue,...
                'ConditionsList',elemConds);
            
            %These lines are required due to Comparators like NumericComparator
            %wanting to modify the display of its ActVal and ExpVal:
            comp = elemComparison.Comparators(elemComparison.SupportedComparatorIndex);
            diag.ActVal = comp.valueToDisplayInDiagnostic(diag.ActVal);
            diag.ExpVal = comp.valueToDisplayInDiagnostic(diag.ExpVal);
        end
        
        function validateSupportsContainer(comparators, value)
            if isempty(comparators.findFirstComparatorFor(value))
                comparators.throwUnsupportedValue(value);
            end
        end
    end
    
    methods(Hidden, Sealed, Static, Access = protected)
        %Required by matlab.mixin.Heterogeneous:
        function instance = getDefaultScalarElement()
            instance = matlab.unittest.internal.constraints.DefaultComparator;
        end
    end
    
    methods(Sealed, Access = private) %Must be Sealed for heterogeneous arrays to work
        function throwUnsupportedValue(comparators,value)
            import matlab.unittest.internal.diagnostics.indent;
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            valueString = ConstraintDiagnostic.getDisplayableString(value);
            valueClass = class(value);
            comparatorsString = indent(comparators.toDisplayableString());
            error(message('MATLAB:unittest:Comparator:ComparatorsDoNotSupportValue',...
                comparatorsString, valueClass, indent(valueString)));
        end

        function str = toDisplayableString(comparators)
            import matlab.unittest.internal.diagnostics.indentWithArrow;
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            if isempty(comparators)
                str = strtrim(ConstraintDiagnostic.getDisplayableString(comparators));
            else
                comparatorStrings = arrayfun(@(x) indentWithArrow(class(x)),...
                        comparators,'UniformOutput',false);
                str = strjoin(comparatorStrings,newline());
            end
        end
    end
end


function bool = deepComparisonIsSupported(comparison)
bool = false;
index = comparison.SupportedComparatorIndex;
if isempty(index)
    return;
end
comp = comparison.Comparators(index);
subComparisonArray = comp.getElementComparisons(comparison);
for k=1:numel(subComparisonArray)
    if ~deepComparisonIsSupported(subComparisonArray(k))
        return;
    end
end
bool = true;
end


function bool = deepComparisonIsSatisfied(comparison)
bool = false;
[actVal,expVal,comp] = getActExpCompFrom(comparison);
if comp.containerSatisfiedBy(actVal,expVal)
    subComparisonArray = comp.getElementComparisons(comparison);
    for k=1:numel(subComparisonArray)
        if ~deepComparisonIsSatisfied(subComparisonArray(k))
            return;
        end
    end
    bool = true;
end
end


function [elemDiag,elemPassed,elemComparison] = getDiagnosticParts(elemDiagFcn,elemComparison,depthToElem)
[actElem,expElem,elemComp] = getActExpCompFrom(elemComparison);

if ~elemComp.containerSatisfiedBy(actElem,expElem)
    elemDiag = elemDiagFcn(elemComp,actElem,expElem);
    validateFunctionGaveDiagnosticOutput(elemDiagFcn,{elemComp,actElem,expElem},elemDiag);
    elemPassed = false;
    return;
end

subComparisonArray = elemComp.getElementComparisons(elemComparison);
for k=1:numel(subComparisonArray)
    subComparison = subComparisonArray(k);
    [subDiag,subPassed,subComparison] = ...
        getDiagnosticParts(elemDiagFcn,subComparison,depthToElem+1);
    if ~subPassed
        elemDiag = subDiag;
        elemPassed = subPassed;
        elemComparison = subComparison;
        return;
    end
end
elemPassed = true;

if depthToElem==0 %Only create passing diagnostic for top level
    elemDiag = elemDiagFcn(elemComp,actElem,expElem);
    validateFunctionGaveDiagnosticOutput(elemDiagFcn,{elemComp,actElem,expElem},elemDiag);
else
    elemDiag = [];
end
end


function [actVal,expVal,comp] = getActExpCompFrom(comparison)
actVal = comparison.ActualValue;
expVal = comparison.ExpectedValue;
comparatorIndex = comparison.SupportedComparatorIndex;
if isempty(comparatorIndex)
    throwUnsupportedValue(comparison.Comparators,expVal);
end
comp = comparison.Comparators(comparatorIndex);
end


function validateFunctionGaveDiagnosticOutput(funcHandle,funcInputs,funcOutput)
import matlab.unittest.internal.diagnostics.indent;
import matlab.unittest.diagnostics.ConstraintDiagnostic;
expType = 'matlab.unittest.diagnostics.Diagnostic';
if ~isa(funcOutput,expType)
    error(message('MATLAB:unittest:Comparator:InvalidOutputType',...
        strtrim(ConstraintDiagnostic.getDisplayableString(funcHandle)),...
        indent(expType),...
        class(funcOutput),...
        indent(ConstraintDiagnostic.getDisplayableString(funcInputs))));
end
end

% LocalWords:  conds func

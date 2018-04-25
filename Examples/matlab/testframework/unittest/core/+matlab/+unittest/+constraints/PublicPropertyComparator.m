classdef PublicPropertyComparator < matlab.unittest.internal.constraints.ContainerComparator & ...
                                    matlab.unittest.internal.mixin.IgnoringPropertiesMixin
    % PublicPropertyComparator - Compare the public properties of MATLAB objects
    %
    %   The PublicPropertyComparator supports MATLAB objects (or arrays of
    %   objects) and performs comparison by recursively comparing data
    %   structures contained in the public properties. By default,
    %   PublicPropertyComparator only supports objects that have no public
    %   properties. However, it can support other data types during recursion
    %   by passing a comparator to the constructor. The supportingAllValues
    %   static method can also be used to construct a PublicPropertyComparator
    %   that supports all MATLAB data types in recursion. PublicPropertyComparator
    %   differs from the isequal function in that it only examines the public
    %   properties of the objects.
    %
    %   PublicPropertyComparator methods:
    %       PublicPropertyComparator - Class constructor
    %       supportingAllValues      - Create a PublicPropertyComparator that supports any value in recursion
    %
    %    PublicPropertyComparator properties:
    %       Recursive         - Boolean indicating whether the instance operates recursively
    %       IgnoredProperties - Properties to ignore
    %
    %   Examples:
    %      import matlab.unittest.constraints.IsEqualTo;
    %      import matlab.unittest.constraints.PublicPropertyComparator;
    %      import matlab.unittest.TestCase;
    %
    %      % Create a TestCase for interactive use
    %      testCase = TestCase.forInteractiveUse;
    %
    %      % Passing case
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','MsgText');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues));
    %
    %      % Failing case
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','msgtext');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues));
    %
    %      % Passing case (the strings are compared ignoring case differences)
    %      m1 = MException('Msg:ID','MsgText');
    %      m2 = MException('Msg:ID','msgtext');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues,'IgnoringCase',true));
    %
    %      % Passing case (some of the properties are ignored)
    %      m1 = MException('Msg:ID1','MsgText');
    %      m2 = MException('Msg:ID2','MsgText');
    %      testCase.verifyThat(m1, IsEqualTo(m2, 'Using', PublicPropertyComparator.supportingAllValues('IgnoringProperties',{'identifier','stack'})));
    %
    %  See also:
    %       matlab.unittest.constraints.IsEqualTo
    %       matlab.unittest.constraints.ObjectComparator
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    properties(Constant, Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:PublicPropertyComparator');
    end
    
    properties(Access=private)
        CycleDetector
    end
    
    methods
        function comparator = PublicPropertyComparator(varargin)
            % PublicPropertyComparator - Class constructor
            %
            %   PublicPropertyComparator creates a comparator for public properties of
            %   MATLAB objects. This comparator supports only empty object arrays or
            %   objects with no public properties.
            %
            %   PublicPropertyComparator(COMPOBJ) creates a comparator for public
            %   properties of MATLAB objects and indicates a comparator, COMPOBJ, that
            %   defines the comparator used to compare public properties.
            %
            %   PublicPropertyComparator(...,'Recursively', true) creates a comparator
            %   for public properties of MATLAB objects and indicates that the
            %   comparator can be reused recursively to compare values contained in
            %   public properties.
            %
            %   PublicPropertyComparator(...,'IgnoringProperties', PROPSTOIGNORE)
            %   creates a comparator for public properties of MATLAB objects which
            %   ignores any public property with a property name listed in the cell
            %   array PROPSTOIGNORE.
            
            import matlab.unittest.internal.constraints.ActualExpectedCycleDetector;
            comparator = comparator@matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
            comparator.CycleDetector = ActualExpectedCycleDetector();
        end
    end
    
    methods(Static)
        function comparator = supportingAllValues(varargin)
            % supportingAllValues - Create a PublicPropertyComparator that supports any value in recursion
            %
            %   PublicPropertyComparator.supportingAllValues creates a
            %   PublicPropertyComparator instance that supports any value in recursion.
            %
            %   PublicPropertyComparator.supportingAllValues(NAME_1, VALUE_1, ...)
            %   creates a PublicPropertyComparator instance that supports any value in
            %   recursion with additional options specified by one or more of the
            %   following Name,Value pair arguments:
            %
            %       * IgnoringCase       - If set to true, then case differences are
            %                              ignored when comparing strings.
            %       * IgnoringFields     - Specifies fields that are to be ignored when
            %                              comparing structs.
            %       * IgnoringProperties - Specified properties that are to be ignored
            %                              when comparing objects.
            %       * IgnoringWhitespace - If set to true, then whitespace differences
            %                              are ignored when comparing strings.
            %       * Within             - Tolerance to apply during comparison,
            %                              specified as an object of type
            %                              matlab.unittest.constraints.Tolerance.
            import matlab.unittest.constraints.PublicPropertyComparator;
            import matlab.unittest.constraints.IsEqualTo;
            
            [ppcArgs,isEqualToArgs] = separateArguments(varargin{:});
            
            %We use IsEqualTo to validate and forward the arguments that
            %are not specific to the PublicPropertyComparator onto the
            %default comparators.
            isEqualToConstraint = IsEqualTo([],isEqualToArgs{:});
            comparators = isEqualToConstraint.Comparator;
            
            %The rest of the arguments are validated and forwarded by the
            %PublicPropertyComparator.
            comparator = PublicPropertyComparator(comparators,'IncludingSelf',true,ppcArgs{:});
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = isaCompatibleObject(value) || isaCompatibleHandleHandleObject(value);
        end
        
        function bool = containerSatisfiedBy(comparator,actVal,expVal)
            bool = haveSameClass(actVal, expVal) && ...
                haveSameSize(actVal, expVal) && ...
                comparator.haveSameUnignoredPropertyNames(actVal, expVal);
        end
        
        function conds = getContainerConditionsFor(comparator,actVal,expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if ~haveSameClass(actVal, expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal, expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            elseif ~comparator.haveSameUnignoredPropertyNames(actVal, expVal)
                conds = comparator.generatePropertiesMismatchCondition(actVal, expVal);
            else
                conds =comparator.generatePassingCondition(actVal, expVal);
            end
        end
        
        function subComparisons = getElementComparisons(comparator,comparison)
            if numel(comparison.ExpectedValue) == 1
                subComparisons = comparator.getComparisonsForScalarObjectProperties(comparison);
            else
                subComparisons = comparator.getComparisonsForObjectArrayElements(comparison);
            end
        end
        
        function bool = isStateful(~)
            bool = true;
        end
        
        function comparator = ignoringPropertiesPostSet(comparator)
            comparator = comparator.forwardNameValue('IgnoringProperties',comparator.IgnoredProperties);
        end
    end
    
    methods(Access=private)
        function subComparisons = getComparisonsForObjectArrayElements(~, comparison)
            import matlab.unittest.constraints.Comparison;
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            numObjects = numel(expVal);
            
            actElementsCell = cell(1,numObjects);
            expElementsCell = cell(1,numObjects);
            for k=1:numObjects
                actElementsCell{k} = actVal(k);
                expElementsCell{k} = expVal(k);
            end
            
            args = {actElementsCell,expElementsCell,{comparison.Comparators}};
            if comparison.IsUsingValueReference
                args{end+1} = arrayfun(@(k) sprintf('%s(%u)',comparison.ValueReference,k),...
                    1:numObjects,'UniformOutput',false);
            end
            subComparisons = Comparison.fromCellArrays(args{:});
        end
                
        function  subComparisons = getComparisonsForScalarObjectProperties(comparator, comparison)
            import matlab.unittest.constraints.Comparison;
            actVal = comparison.ActualValue;
            expVal = comparison.ExpectedValue;
            
            if comparator.CycleDetector.haveAlreadyVisited(actVal, expVal)
                subComparisons = comparator.EmptyComparisonArray;
                return;
            end
            comparator.CycleDetector = comparator.CycleDetector.visit(actVal, expVal);
            
            propertyNames = comparator.getUnignoredProperties(expVal);
            numProps = numel(propertyNames);
            
            actPropValsCell = cell(1,numProps);
            expPropValsCell = cell(1,numProps);
            for k=1:numProps
                actPropValsCell{k} = actVal.(propertyNames{k});
                expPropValsCell{k} = expVal.(propertyNames{k});
            end
            
            comparators = comparator.getComparatorsForElements(comparison);
            
            args = {actPropValsCell,expPropValsCell,{comparators}};
            if comparison.IsUsingValueReference
                args{end+1} = cellfun(@(propName) sprintf('%s.%s',comparison.ValueReference,propName),...
                    propertyNames,'UniformOutput',false);
            end
            subComparisons = Comparison.fromCellArrays(args{:});
        end
                
        function bool = haveSameUnignoredPropertyNames(comparator,actVal, expVal)
            actProps = comparator.getUnignoredProperties(actVal);
            expProps = comparator.getUnignoredProperties(expVal);
            
            bool = (numel(actProps) == numel(expProps)) && ...
                all(strcmp(sort(actProps),sort(expProps)));
        end
        
        function propertyNames = getUnignoredProperties(comparator,value)
            propertyNames = properties(value);
            if ~isempty(comparator.IgnoredProperties)
                %toColumn is needed since setdiff may return an empty row on scalar input
                propertyNames = toColumn(setdiff(propertyNames,comparator.IgnoredProperties,'stable'));
            end
        end
        
        function cond = generatePropertiesMismatchCondition(comparator, actVal, expVal)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            actProps = comparator.getUnignoredProperties(actVal);
            expProps = comparator.getUnignoredProperties(expVal);

            cond = ConstraintDiagnostic();
            cond.DisplayDescription = true;
            cond.DisplayConditions = true;
            
            cond.Description = comparator.Catalog.getString('PropertiesMismatch');
            if ~isempty(comparator.IgnoredProperties)
                propsIgnoredStr = sprintf('%s\n%s',...
                    comparator.Catalog.getString('PropertiesToIgnore'),...
                    getIndentedPropertyListStr(comparator.IgnoredProperties));
                
                cond.Description = sprintf('%s\n%s',...
                    cond.Description,...
                    propsIgnoredStr);
            end
            
            extraActProps = setdiff(actProps,expProps);
            if ~isempty(extraActProps)
                extraActPropsStr = getIndentedPropertyListStr(extraActProps);
                cond.addCondition(FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('ExtraProperties'),...
                    extraActPropsStr)));
            end
            
            extraExpProps = setdiff(expProps,actProps);
            if ~isempty(extraExpProps)
                extraExpPropsStr = getIndentedPropertyListStr(extraExpProps);
                cond.addCondition(FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('MissingProperties'),...
                    extraExpPropsStr)));
            end
        end
        
        function cond = generatePassingCondition(comparator, ~, ~)
            import matlab.unittest.diagnostics.Diagnostic;
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            propsToIgnore = comparator.IgnoredProperties;
            
            if isempty(propsToIgnore)
                cond = Diagnostic.empty(1,0);
            else
                propsIgnoredStr = FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('PropertiesToIgnore'),...
                    getIndentedPropertyListStr(propsToIgnore)));
                cond = Diagnostic.join(propsIgnoredStr);
            end
        end
    end
end


function bool = haveSameClass(actVal, expVal)
bool = strcmp(class(actVal), class(expVal));
end


function bool = haveSameSize(actVal, expVal)
bool = isequal(size(expVal), size(actVal));
end


function x = toColumn(x)
x = reshape(x,[],1);
end


function bool = isaCompatibleObject(value)
if ~isobject(value)
    bool = false;
    return;
end
mc = metaclass(value);
bool = ~isempty(mc) && ...
    canAccessAllProperties(value,{mc.MethodList.Name});
end


function bool = isaCompatibleHandleHandleObject(value)
bool = isa(value, 'handle.handle') && ...
    hasNoForbiddenMethods(methods(value));
end


function bool = canAccessAllProperties(value,methodNames)
bool = hasNoForbiddenMethods(methodNames) && ...
    isNotMultiElementIndexingParenObject(value);
end


function bool = hasNoForbiddenMethods(methodNames)
bool = isempty(methodNames) || ...
    ~any(ismember({'properties','numel','subsref'},methodNames));
end


function bool = isNotMultiElementIndexingParenObject(value)
bool = numel(value)<=1 || ~isa(value,'matlab.mixin.internal.indexing.Paren');
end


function [ppcArgs,isEqualToArgs] = separateArguments(varargin)
p = matlab.unittest.internal.strictInputParser;
p.KeepUnmatched = true;

%We do not want to allow 'Using', so instead of sending it to IsEqualTo we
%send it to the PublicPropertyComparator to produce an error.
p.addParameter('Using',[]);

%Parameters associated with PublicPropertyComparator:
p.addParameter('IgnoringProperties',[]);
p.addParameter('IncludingSiblings',[]);

p.parse(varargin{:});
ppcArgs = struct2args(rmfield(p.Results, p.UsingDefaults));
isEqualToArgs = struct2args(p.Unmatched);
end


function args = struct2args(s)
args = reshape([fieldnames(s), struct2cell(s)].', 1, []);
end


function d = getIndentedPropertyListStr(props)
import matlab.unittest.internal.diagnostics.indent;
d = indent(char(join("'" + props + "'", newline)));
end

% LocalWords:  msgtext COMPOBJ PROPSTOIGNORE ppc Unignored conds Vals
% LocalWords:  Formattable

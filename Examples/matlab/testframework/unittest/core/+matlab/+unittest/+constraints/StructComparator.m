classdef StructComparator < matlab.unittest.internal.constraints.ContainerComparator & ...
                            matlab.unittest.internal.mixin.IgnoringFieldsMixin
    % StructComparator - Comparator for comparing MATLAB structs.
    %
    %   The StructComparator natively supports structs (or arrays of
    %   structs) and performs a comparison by recursively examining the
    %   input data structures. By default, a struct comparator only
    %   supports empty struct arrays. However, it can support other data
    %   types during recursion by passing a comparator to the constructor.
    %
    %    StructComparator methods:
    %       StructComparator - Class constructor
    %
    %   StructComparator properties:
    %       Recursive     - Boolean indicating whether the instance operates recursively
    %       IgnoredFields - Fields to ignore
    %
    %   See also:
    %       matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(Constant,Access=private)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:StructComparator');
    end
    
    methods
        function comparator = StructComparator(varargin)
            % StructComparator - Class constructor
            %
            %   StructComparator creates a comparator for MATLAB struct arrays. This
            %   comparator supports only empty struct arrays or structs with no fields.
            %
            %   StructComparator(COMPOBJ) creates a comparator for MATLAB struct arrays
            %   indicating a comparator, COMPOBJ, that defines the comparator used to
            %   compare values contained in the struct.
            %
            %   StructComparator(...,'Recursively', true) creates a comparator for
            %   MATLAB struct arrays and indicates that the comparator can be reused
            %   recursively to compare values contained in struct fields.
            %
            %   StructComparator(...,'IgnoringFields', FIELDSTOIGNORE) creates a
            %   comparator for MATLAB struct arrays which ignores any fields with a
            %   field name listed in the cell array FIELDSTOIGNORE.
            
            comparator = comparator@matlab.unittest.internal.constraints.ContainerComparator(varargin{:});
        end
    end
    
    methods(Hidden, Access=protected)
        function bool = supportsContainer(~, value)
            bool = builtin('isstruct',value);
        end
        
        function bool = containerSatisfiedBy(comparator,actVal,expVal)
            bool = haveSameClass(actVal, expVal) && ...
                haveSameSize(actVal, expVal) && ...
                comparator.haveSameUnignoredFieldNames(actVal, expVal);
        end
        
        function conds = getContainerConditionsFor(comparator,actVal,expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            
            if ~haveSameClass(actVal, expVal)
                conds = ConstraintDiagnosticFactory.generateClassMismatchDiagnostic(actVal, expVal);
            elseif ~haveSameSize(actVal, expVal)
                conds = ConstraintDiagnosticFactory.generateSizeMismatchDiagnostic(actVal, expVal);
            elseif ~comparator.haveSameUnignoredFieldNames(actVal, expVal)
                conds = comparator.generateFieldsMismatchCondition(actVal, expVal);
            else
                conds =comparator.generatePassingCondition(actVal, expVal);
            end
        end
        
        function subComparisons = getElementComparisons(comparator,comparison)
            import matlab.unittest.constraints.Comparison;
            actVal = orderfields(comparator.removeIgnoredFieldsFrom(comparison.ActualValue));
            expVal = orderfields(comparator.removeIgnoredFieldsFrom(comparison.ExpectedValue));
            
            actElementsCell = reshape(struct2cell(actVal),1,[]);
            expElementsCell = reshape(struct2cell(expVal),1,[]);
            comparators = comparator.getComparatorsForElements(comparison);
            
            args = {actElementsCell,expElementsCell,{comparators}};
            if comparison.IsUsingValueReference
                args{end+1} = generateSubReferenceCell(expVal,comparison.ValueReference);
            end
            subComparisons = Comparison.fromCellArrays(args{:});
        end
        
        function comparator = ignoringFieldsPostSet(comparator)
            comparator = comparator.forwardNameValue('IgnoringFields',comparator.IgnoredFields);
        end
    end
    
    methods(Access = private)
        function bool = haveSameUnignoredFieldNames(comparator,actVal, expVal)
            actFields = comparator.getUnignoredFieldnames(actVal);
            expFields = comparator.getUnignoredFieldnames(expVal);

            bool = (numel(actFields) == numel(expFields)) && ...
                all(strcmp(sort(actFields),sort(expFields)));
        end
        
        function fieldNames = getUnignoredFieldnames(comparator,value)
            fieldNames = fieldnames(value);
            if ~isempty(comparator.IgnoredFields)
                %toColumn is needed since setdiff may return an empty row on scalar input
                fieldNames = toColumn(setdiff(fieldNames,comparator.IgnoredFields,'stable'));
            end
        end
        
        function cond = generateFieldsMismatchCondition(comparator, actVal, expVal)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            actFields = comparator.getUnignoredFieldnames(actVal);
            expFields = comparator.getUnignoredFieldnames(expVal);
            
            cond = ConstraintDiagnostic();
            cond.DisplayDescription = true;
            cond.DisplayConditions = true;
            
            cond.Description = comparator.Catalog.getString('FieldsMismatch');
            if ~isempty(comparator.IgnoredFields)
                fieldsIgnoredStr = sprintf('%s\n%s',...
                    comparator.Catalog.getString('FieldsToIgnore'),...
                    getIndentedFieldListStr(comparator.IgnoredFields));
                
                cond.Description = sprintf('%s\n%s',...
                    cond.Description,...
                    fieldsIgnoredStr);
            end
            
            extraActFields = setdiff(actFields,expFields);
            if ~isempty(extraActFields)
                extraActFieldsStr = getIndentedFieldListStr(extraActFields);
                cond.addCondition(FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('ExtraFields'),...
                    extraActFieldsStr)));
            end
            
            extraExpFields = setdiff(expFields,actFields);
            if ~isempty(extraExpFields)
                extraExpFieldsStr = getIndentedFieldListStr(extraExpFields);
                cond.addCondition(FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('MissingFields'),...
                    extraExpFieldsStr)));
            end
        end
        
        function cond = generatePassingCondition(comparator, ~, ~)
            import matlab.unittest.diagnostics.Diagnostic;
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            fieldsToIgnore = comparator.IgnoredFields;
            
            if isempty(fieldsToIgnore)
                cond = Diagnostic.empty(1,0);
            else
                fieldsIgnoredStr = FormattableStringDiagnostic(sprintf('%s\n%s',...
                    comparator.Catalog.getString('FieldsToIgnore'),...
                    getIndentedFieldListStr(fieldsToIgnore)));
                cond = Diagnostic.join(fieldsIgnoredStr);
            end
        end

        function structArray = removeIgnoredFieldsFrom(comparator,structArray)
            if ~isempty(comparator.IgnoredFields)
                fieldNames = fieldnames(structArray);
                fieldNamesToRemoveMask = ismember(fieldNames,comparator.IgnoredFields);
                fieldNamesToRemove = fieldNames(fieldNamesToRemoveMask);
                structArray = rmfield(structArray,fieldNamesToRemove);
            end
        end
    end
end


function subReferenceCell = generateSubReferenceCell(value, valueReference)
fieldNames = fieldnames(value);
numOfStructs = numel(value);
numOfFields = numel(fieldNames);
subReferenceCell = cell(1,numOfStructs*numOfFields);

currentIdx = 0;
for structIdx=1:numOfStructs
    structIndexStr = '';
    if numOfStructs ~= 1
        structIndexStr = sprintf('(%u)',structIdx);
    end
    for fieldIdx=1:numOfFields
        currentIdx = currentIdx + 1;
        subReferenceCell{currentIdx} = sprintf('%s%s.%s',...
            valueReference, structIndexStr, fieldNames{fieldIdx});
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


function d = getIndentedFieldListStr(fieldNames)
import matlab.unittest.internal.diagnostics.indent;
d = indent(char(join("'" + fieldNames + "'", newline)));
end

% LocalWords:  COMPOBJ FIELDSTOIGNORE Unignored conds Formattable

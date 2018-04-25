classdef HasUniqueElements < matlab.unittest.constraints.BooleanConstraint
    % HasUniqueElements - Constraint specifying a set that contains unique elements
    %
    %   The HasUniqueElements constraint produces a qualification failure
    %   for any actual value that does not contain unique elements.
    %   An actual value is considered to have unique elements if
    %   numel(unique(actual)) is equal to numel(actual).
    %
    %   HasUniqueElements methods:
    %       HasUniqueElements - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasUniqueElements;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('abc', HasUniqueElements);
    %
    %       testCase.fatalAssertThat(magic(6), HasUniqueElements);
    %
    %       testCase.verifyThat(table([3;3;5],{'A';'C';'E'},logical([1;0;0])),HasUniqueElements);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat(abs(-5:5), HasUniqueElements);
    %
    %       testCase.assertThat('mississippi', HasUniqueElements);
    %
    %       testCase.assumeThat({'abc','123';'abc','345'},HasUniqueElements);
    %
    %   See also:
    %       UNIQUE
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    
    methods
        function constraint = HasUniqueElements()
            % HasUniqueElements - Class constructor
            %
            %   HasUniqueElements creates a constraint that uses UNIQUE to
            %   determine whether a value has unique elements.
        end
        
        function bool = satisfiedBy(~, actual)
            bool = isunique(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            [isUniq,cellOfDupInds] = isunique(actual);
            
            if ~isUniq
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive,actual);
                subDiag = generateNonUniqueElementsDiagnostic(actual,cellOfDupInds);
                diag.addCondition(subDiag);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            [isUniq,cellOfDupInds] = isunique(actual);
            
            if isUniq
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative,actual);
                diag.addCondition(message('MATLAB:unittest:HasUniqueElements:ElementsAreUnique'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                subDiag = generateNonUniqueElementsDiagnostic(actual,cellOfDupInds);
                diag.addCondition(subDiag);
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
end

function diag = generateNonUniqueElementsDiagnostic(actual,cellOfDuplicateInds)
import matlab.unittest.internal.supportsArrayIndexing;
import matlab.unittest.diagnostics.ConstraintDiagnostic;
import matlab.unittest.internal.diagnostics.indent;
import matlab.internal.Catalog;

catalog = Catalog('MATLAB:unittest:HasUniqueElements');
numOfDuplicatedElements = size(cellOfDuplicateInds,1);

diag = ConstraintDiagnostic();
diag.DisplayDescription = true;
diag.DisplayConditions = true;

if numOfDuplicatedElements > 5
    diag.Description = catalog.getString('ContainsNonuniqueElementsFirst5',numOfDuplicatedElements);
else
    diag.Description = catalog.getString('ContainsNonuniqueElements',numOfDuplicatedElements);
end

arrayIndexingSupported = supportsArrayIndexing(actual);
for k=1:min(numOfDuplicatedElements,5)
    inds = cellOfDuplicateInds{k};
    if arrayIndexingSupported
        element = actual(inds(1));
        elementString = createElementDisplayStr(element);
        condStr = catalog.getString('ElementAtIndices',mat2str(inds),indent(elementString));
    else
        condStr = catalog.getString('IndicesOfElement',mat2str(inds));
    end
    diag.addCondition(condStr);
end
end

function [bool, cellOfDupInds] = isunique(value)
if nargout < 2
    bool = numel(unique(value)) == numel(value);
else
    [uniqValue,~,ic] = unique(value);
    bool = numel(uniqValue) == numel(value);
    cellOfDupInds = getCellOfDuplicateInds(ic);
end
end

function cellOfDupInds = getCellOfDuplicateInds(ic)
ic = reshape(ic,1,[]);
uniqueIC = unique(ic);
cellOfDupInds = cell(numel(uniqueIC),1);
count = 0;
for icElem = uniqueIC
    mask = ic==icElem;
    if nnz(mask)>1
        count = count+1;
        cellOfDupInds{count} = find(mask);
    end
end
cellOfDupInds = cellOfDupInds(1:count);
end

function str = createElementDisplayStr(element)
import matlab.unittest.internal.diagnostics.getDisplayableStringWithNoHeader;
import matlab.unittest.internal.diagnostics.getDisplayableString;
if isobject(element)
    str = char(getDisplayableString(element));
else
    str = char(getDisplayableStringWithNoHeader(element));
end
end
classdef (Hidden) CombiningTolerance < matlab.unittest.internal.constraints.ElementwiseTolerance
    % This class is undocumented and may change in a future release.
    %
    %   See also ElementwiseTolerance/and ElementwiseTolerance/or

    %  Copyright 2012-2017 The MathWorks, Inc.

    properties (Abstract, Hidden, Constant, GetAccess = protected)
        % BooleanOperator - Boolean logic for combining two ElementwiseTolerances
        %   It must be specified as a function handle.
        BooleanOperator;
    end
    
    properties (Hidden, SetAccess = private)
        % Left tolerance that is being AND'ed or OR'ed -- must be an ElementwiseTolerance
        FirstTolerance
        
        % Right tolerance that is being AND'ed or OR'ed -- must be an ElementwiseTolerance
        SecondTolerance
    end
    
    methods
        function tolerance = CombiningTolerance(firstTolerance, secondTolerance)
            % CombiningTolerance - Construct a CombiningTolerance from two
            %   ElementwiseTolerances.
            
            validateattributes(firstTolerance, {'matlab.unittest.internal.constraints.ElementwiseTolerance'}, ....
                {'scalar'}, '', 'firstTolerance');
            validateattributes(secondTolerance, {'matlab.unittest.internal.constraints.ElementwiseTolerance'}, ...
                {'scalar'}, '', 'secondTolerance');
            
            [combinedTypes, combinedSizes] = matlab.unittest.internal.constraints.CombiningTolerance.combineTypesAndSizes(firstTolerance, secondTolerance);
            tolerance = tolerance@matlab.unittest.internal.constraints.ElementwiseTolerance(combinedTypes, combinedSizes);
            
            tolerance.FirstTolerance = firstTolerance;
            tolerance.SecondTolerance = secondTolerance;
        end
    end
    
    methods (Hidden, Access = protected)
        function comp = elementsSatisfiedBy(tolerance, actVal, expVal, mask)
            comp = tolerance.BooleanOperator(...
                tolerance.FirstTolerance.elementsSatisfiedBy(actVal, expVal, mask),...
                tolerance.SecondTolerance.elementsSatisfiedBy(actVal, expVal, mask));
        end
    end
    
    methods
        function diag = getDiagnosticFor(tolerance, actVal, expVal)
            % getDiagnosticFor - Returns a diagnostic object containing
            %   information about the result of a comparison.
            diag = tolerance.getConstraintDiagnosticFor(actVal, expVal);
            diag.enableWarnOnUseFor(tolerance);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(tolerance, actVal, expVal)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.getSimpleParentName;
            
            % Early return if there is a discrepancy (size, type, sparsity, etc.)
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            failedIndices = tolerance.getFailedIndices(actVal, expVal);
            
            isSatisfied = false;
            if ~isempty(failedIndices)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive);
                isSatisfied = true;
            end
            diag.DisplayConditions = true;
            
            % Diagnostic from first tolerance
            diag1 = getAppropriateDiagnosticFor(tolerance.FirstTolerance, actVal, expVal);
            diag1.DisplayActVal = false;
            diag1.DisplayExpVal = false;
            
            % Diagnostic from second tolerance
            diag2 = getAppropriateDiagnosticFor(tolerance.SecondTolerance, actVal, expVal);
            diag2.DisplayActVal = false;
            diag2.DisplayExpVal = false;
            
            % Add both conditions
            diag.addCondition(diag1);
            diag.addCondition(diag2);
            
            if isSatisfied
                % For passing condition, we do not display the failure
                % table.
                return
            end
            
            % If we reach here, we need to display overall failure table.
            % So, gather the tolerance types and values to be displayed
            firstTolerance  = tolerance.FirstTolerance;
            secondTolerance = tolerance.SecondTolerance;
            tolData = {};
            
            % Pick up simple ToleranceWithValues instances that support
            % the expected value
            if metaclass(firstTolerance) <= ?matlab.unittest.internal.constraints.ToleranceWithValues && ...
                    firstTolerance.supports(expVal)
                tolData{end+1} = getSimpleParentName(class(firstTolerance));
                tolData{end+1} = firstTolerance.getToleranceValueFor(expVal);
            end
            
            if metaclass(secondTolerance) <= ?matlab.unittest.internal.constraints.ToleranceWithValues && ...
                    secondTolerance.supports(expVal)
                tolData{end+1} = getSimpleParentName(class(secondTolerance));
                tolData{end+1} = secondTolerance.getToleranceValueFor(expVal);
            end
            
            if isempty(tolData)
                % If no ToleranceWithValues classes are gathered, it
                % indicates that all failure tables to be displayed are
                % already accounted for. For example, A CombinedTolerance
                % that combines two CombinedTolerance instances will have
                % all necessary failure tables diagnosed by the inner two
                % CombinedTolerance instances already. The outer most
                % CombinedTolerance has nothing left to display.
                %
                % Example:
                % ToleranceWithValues1 & ToleranceWithValues2 | ...
                %           ToleranceWithValues3 & ToleranceWithValues4
                return;
            end
            
            tolDiag = ConstraintDiagnosticFactory.generateFailureTableDiagnostic(...
                failedIndices, ...
                actVal, ...
                expVal, ...
                tolData{:});
            diag.addCondition(tolDiag);
        end
    end
    
    methods (Static, Access = private)
        function [combinedTypes, combinedSizes] = combineTypesAndSizes(tol1, tol2)
            % combineTypesAndSizes - Combine type and size information from two ElementwiseTolerances.
            %   Validation is also performed to ensure that the two
            %   tolerances being combined are compatible. An error is
            %   thrown if the objects are not compatible.
            
            % Start with the types that are specified in only one of the
            % two tolerances. These need no further validation and can
            % simply be concatenated together.
            [combinedTypes, sizeInd1, sizeInd2] = setxor(tol1.Types, tol2.Types, 'stable');
            combinedSizes = {tol1.Sizes{sizeInd1}, tol2.Sizes{sizeInd2}};
            
            % Next consider the data types which are specified in both
            % tolerances. The types can be take as-is.
            commonTypes = intersect(tol1.Types, tol2.Types);
            combinedTypes = [combinedTypes, commonTypes];
            
            % Validate sizes for each data type which is specified in both
            % tolerances. Also allow scalar expansion (i.e., allow
            % scalar/array combinations). In the case of scalar expansion,
            % return the non-scalar size.
            for type = commonTypes
                size1 = tol1.getSizeFromType(type{1});
                size2 = tol2.getSizeFromType(type{1});
                if isequal(size1, [1,1])
                    newSize = size2;
                elseif isequal(size2, [1,1]) || isequal(size1, size2)
                    newSize = size1;
                else
                    error(message('MATLAB:unittest:Tolerance:SizeMismatch', type{1}));
                end
                
                combinedSizes = [combinedSizes, {newSize}]; %#ok<AGROW>
            end
        end                
    end
end

function diag = getAppropriateDiagnosticFor(tolerance, varargin)
% Diagnose casual diagnostics of ElementwiseTolerance when available
if isa(tolerance,'matlab.unittest.internal.constraints.CasualToleranceDiagnosticMixin')
    diag = tolerance.getCasualDiagnosticFor(varargin{:});
else
    diag = tolerance.getConstraintDiagnosticFor(varargin{:});
end
end


% LocalWords:  Elementwise AND'ed OR'ed unittest

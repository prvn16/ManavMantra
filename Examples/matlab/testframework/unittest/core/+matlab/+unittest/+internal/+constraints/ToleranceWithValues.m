classdef(Hidden) ToleranceWithValues < matlab.unittest.internal.constraints.ElementwiseTolerance    
    % This class is undocumented and may change in a future release.
    
    %ToleranceWithValues    Abstract base class for element-wise tolerance types with values   
    %   Subclasses of ToleranceWithValues implement a Values property and
    %   compareValues method that performs element-wise comparison of the
    %   actual and expected values returning a boolean array. 
    %
    %  Copyright 2014-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Values - Tolerance values
        %   Values is a cell array of numeric arrays. Each element in the
        %   cell array contains the tolerance specification for a
        %   particular data type. Each numeric array may be a scalar or
        %   array of size equal to the actual and expected values.
        Values;
    end
    
    methods (Abstract, Hidden, Access = protected)
        % compareValues - Compares the actual and expected values
        %   Returns a boolean array indicating whether the actual and
        %   expected values are within the tolerance value on an element-wise basis.
        comp = compareValues(actVal, expVal, tolVal);
    end
    
    methods (Access = protected)
        function tolerance = ToleranceWithValues(values)
            
            % Validate the tolerance values
            validateattributes(values, {'cell'}, {'vector', 'nonempty'}, '', 'values');
            
            cellfun(@(val)validateToleranceValue(val), values);
            function validateToleranceValue(val)
                if ~isa(val, 'numeric') && ~isobject(val)
                    error(message('MATLAB:unittest:Tolerance:InvalidToleranceType'));
                end
                if isempty(val) || ~isreal(val) || any(val(:) < 0) || ~all(isfinite(val(:)))
                    error(message('MATLAB:unittest:Tolerance:InvalidToleranceValue'));
                end
            end            
            
            % Assign type and size information.
            types = cellfun(@(tol)class(tol), values, 'UniformOutput',false);
            sizes = cellfun(@size, values, 'UniformOutput',false);                        
            tolerance = tolerance@matlab.unittest.internal.constraints.ElementwiseTolerance(types, sizes);
            
            tolerance.Values = values;
        end
    end
    
    methods (Hidden, Access = protected)
        function comp = elementsSatisfiedBy(tolerance, actVal, expVal, mask)
            % elementsSatisfiedBy - Element-wise satisfaction when comparing actual and expected values
            %   Depends on subclass implementation of compareValues to
            %   determine satisfaction. When the expected value is
            %   unsupported, it returns a array of logical zeros with the
            %   same size as the expected value.
            
            if ~tolerance.supports(expVal)
                comp = false(size(expVal(mask)));
                return;
            end
            
            tolVal = getToleranceValueFor(tolerance, expVal);
            
            if ~isscalar(tolVal)
                tolVal = tolVal(mask);
            end 
            
            comp = compareValues(tolerance, actVal(mask), expVal(mask), tolVal);
        end
        
        function cond = produceFailureCondition(tolerance, actVal, expVal)
            % produceFailureCondition
            %
            %    The produceFailureCondition method contains boiler-plate code
            %    for producing a standard diagnostic for tolerances. It
            %    includes code for displaying failure table with
            %    corresponding tolerance values and types. It allows the
            %    specification of a failing condition string using the
            %    tolerance description argument. It is assumed that the
            %    tolerance supports actVal/expVal when this method is
            %    called.
            
            import matlab.unittest.diagnostics.Diagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.getSimpleParentName;
            
            failedIndices = tolerance.getFailedIndices(actVal, expVal);
            
            if ~isempty(failedIndices)
                % Get tolerance type and values
                tolType = getSimpleParentName(class(tolerance));
                tolVal  = tolerance.getToleranceValueFor(expVal);
                
                % Create failure table diagnostic
                cond = ConstraintDiagnosticFactory.generateFailureTableDiagnostic(...
                    failedIndices, ...
                    actVal, ...
                    expVal, ...
                    tolType, ...
                    tolVal);
            else
                cond = Diagnostic.empty(1,0);
            end
        end
    end
    
    methods (Hidden)
        function tolVal = getToleranceValueFor(tolerance, expVal)
            % getToleranceValueFor - Return the tolerance value for a
            %   given expected value applying the tolerance value mask. It
            %   is assumed that this method will only be called from
            %   subclasses which have a Values property (e.g.,
            %   AbsoluteTolerance or RelativeTolerance).
            
            tolVal = tolerance.Values{strcmp(tolerance.Types, class(expVal))};
            
            if ~isscalar(tolVal)
                tolSize = size(tolVal);
                tolSize(end+1:ndims(expVal)) = 1;
                tolVal = repmat(tolVal, size(expVal) ./ tolSize);
            end 
        end
    end
    
end

% LocalWords:  Elementwise unittest

classdef(Hidden) ElementwiseTolerance < matlab.unittest.constraints.Tolerance
    % This class is undocumented and may change in a future release.
    
    %ElementwiseTolerance   Abstract base class for element-wise tolerance types
    %   This is a numeric tolerance for comparing arrays on an element-wise
    %   basis. Subclasses of ElementwiseTolerance implement an
    %   elementsSatisfiedBy method that determines element-wise
    %   satisfaction when comparing actual and expected values and returns
    %   a boolean array.
    %
    % ElementwiseTolerance methods:
    %   elementsSatisfiedBy - Element-wise satisfaction comparing actual and expected values
    %   and - the logical element-wise conjunction of a tolerance
    %   or - the logical element-wise disjunction of a tolerance
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess = immutable, GetAccess = protected)
        % Types - A cell array of strings containing class names
        %   Types specifies the datatype of each tolerance value.
        Types;
        
        % Sizes - A cell array of numeric scalars
        %   Sizes specifies the size of each tolerance value.
        Sizes;
    end

    methods (Access = protected)
        function tolerance = ElementwiseTolerance(types, sizes)            
            if numel(types) ~= numel(unique(types))
                error(message('MATLAB:unittest:Tolerance:DuplicateType'));
            end            
            tolerance.Types = types;
            tolerance.Sizes = sizes;
        end
    end
    
    methods
        function bool = supports(tolerance, value)
            % supports - Returns a boolean indicating whether the tolerance supports the specified value.
            
            bool = tolerance.hasType(class(value));
        end
        
        function tf = satisfiedBy(tolerance, actVal, expVal)
            %satisfiedBy   Method for determining tolerance satisfaction.
            %
            %   This method returns a logical value indicating whether the tolerance has 
            %   been satisfied by the provided actual and expected values.
            %
            %   Element-wise tolerances require that actual and expected values be scalars or
            %   arrays of the same size and type. The tolerance values must also be a
            %   scalar or array of the same size and type as the actual and expected values.
            
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            tf = false;
            
            if ~tolerance.supports(expVal)
                return;
            end
            
            if isreal(actVal) && isreal(expVal)
                mask = getValuesToCompareMask(actVal, expVal);
                tf = tolerance.allElementsSatisfiedBy(actVal, expVal, mask);
            else
                actRealVal = real(actVal);
                actImagVal = imag(actVal);
                expRealVal = real(expVal);
                expImagVal = imag(expVal);
                
                realMask = getValuesToCompareMask(actRealVal, expRealVal);
                imagMask = getValuesToCompareMask(actImagVal, expImagVal);
                
                % Values where there are no matching Inf/NaNs in either the
                % real or complex part.
                if ~tolerance.allElementsSatisfiedBy(actVal, expVal, realMask & imagMask)
                    return;
                end
                
                % Values where the real part has matching Inf/NaNs
                if ~tolerance.allElementsSatisfiedBy(actImagVal, expImagVal, ~realMask & imagMask)
                    return;
                end
                
                % Values where the imaginary part has matching Inf/NaNs
                tf = tolerance.allElementsSatisfiedBy(actRealVal, expRealVal, realMask & ~imagMask);
            end
        end
    end
    
    methods (Hidden, Access = protected)
        function validateActualExpectedValues(tolerance, actVal, expVal)
            %validateActualExpectedValues   Utility method for validation of actual and expected values.
            %
            %   Any comparator which delegates comparison to an
            %   ElementwiseTolerance should first perform checks to make sure that
            %   the size, class, and sparsity of the actual and expected values are
            %   equivalent. This method performs a sanity check and errors if these
            %   conditions are not satisfied.
            
            % In the future, we might loosen the requirement that the actual and
            % expected value have the same size, class, and sparsity if use cases
            % are discovered where these checks do not make sense (for example, a
            % custom MATLAB object could define its own notion of size such that
            % the size check below could fail yet the two instances are still
            % considered equal).
            
            if ~isa(expVal, 'numeric') && ~isobject(expVal)
                error(message('MATLAB:unittest:Tolerance:InvalidExpectedValueType'));
            end
            
            if ~isequal(size(expVal), size(actVal))
                error(message('MATLAB:unittest:Tolerance:ActExpSizeMismatch'));
            end
            if ~strcmp(class(actVal), class(expVal))
                error(message('MATLAB:unittest:Tolerance:ActExpClassMismatch'));
            end
            if issparse(expVal) ~= issparse(actVal)
                error(message('MATLAB:unittest:Tolerance:ActExpSparsityMismatch'));
            end
            
            % Also validate the expected value size
            if tolerance.supports(expVal)
                tolSize = tolerance.getSizeFromType(class(expVal));
                if ~areSizesCompatible(tolSize, size(expVal))
                    error(message('MATLAB:unittest:Tolerance:TolAndExpValSizeMismatch'));
                end
            end
        end
        
        function bool = hasType(tolerance, type)
            % Returns a boolean indicating whether the ElementwiseTolerance
            % contains a tolerance for a particular data type.
            
            bool = nnz(strcmp(tolerance.Types, type)) == 1;
        end
        
        function sz = getSizeFromType(tolerance, type)
            % Return the tolerance size for a given data type.
            
            sz = tolerance.Sizes{strcmp(tolerance.Types, type)};
        end
        
        function idx = getFailedIndices(tolerance, actVal, expVal)
            if isreal(actVal) && isreal(expVal)
                mask = getValuesToCompareMask(actVal, expVal);
                idx = tolerance.getFailedIndicesWithMask(actVal, expVal, mask);
            else
                actRealVal = real(actVal);
                actImagVal = imag(actVal);
                expRealVal = real(expVal);
                expImagVal = imag(expVal);
                
                realMask = getValuesToCompareMask(actRealVal, expRealVal);
                imagMask = getValuesToCompareMask(actImagVal, expImagVal);
                
                % Values where there are no matching Inf/NaNs in either the
                % real or complex part.
                idx1 = tolerance.getFailedIndicesWithMask(actVal, expVal, realMask & imagMask);
                
                % Values where the real part has matching Inf/NaNs
                idx2 = tolerance.getFailedIndicesWithMask(actImagVal, expImagVal, ~realMask & imagMask);
                
                % Values where the imaginary part has matching Inf/NaNs
                idx3 = tolerance.getFailedIndicesWithMask(actRealVal, expRealVal, realMask & ~imagMask);
                
                idx = sort([idx1, idx2, idx3]);
            end
        end
    end
    
    methods (Access = private)
        function bool = allElementsSatisfiedBy(tolerance, actVal, expVal, mask)
            if ~any(mask)
                bool = true;
                return;
            end            
            comp = tolerance.elementsSatisfiedBy(actVal, expVal, mask);
            bool = full(all(comp(:)));
        end
        
        function idx = getFailedIndicesWithMask(tolerance, actVal, expVal, mask)
            if ~any(mask)
                idx = [];
                return;
            end
            
            comp = tolerance.elementsSatisfiedBy(actVal, expVal, mask);
            
            % Find the failed indices, translating back to the full size of
            % the actual and expected values.
            idx = reshape(find(mask),1,[]);
            idx = idx(~comp);
        end
    end
    
    methods (Abstract, Hidden, Access = protected)
        % elementsSatisfiedBy - Element-wise satisfaction when comparing actual and expected values.
        %   Returns a boolean array indicating whether the actual and
        %   expected values satisfy the tolerance on an element-wise basis.
        %   This method should return a correctly-sized array of logical
        %   zeros if the expected value is not supported. It operates on a
        %   mask that provides indices for comparison.
        comp = elementsSatisfiedBy(tolerance, actVal, expVal, mask);
    end
                
    methods (Sealed)
        function tolerance = and(tolerance1, tolerance2)
            % and - the logical element-wise conjunction of a tolerance
            %
            %   and(tolerance1, tolerance2) returns a tolerance which is
            %   the boolean conjunction of tolerance1 and tolerance2. This
            %   is a means to specify that every element of the actual
            %   value should be equal to the expected value to within the
            %   tolerance specified by both tolerance1 and tolerance2. A
            %   qualification failure should be produced when either
            %   tolerance1 or tolerance2 is not satisfied for one or more
            %   elements of the values being compared.
            %
            %   Typically, the AND method is not called directly, but the
            %   MATLAB "&" operator is used to denote the conjunction of
            %   any two ElementwiseTolerance objects.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Passing qualifications
            %       testCase.verifyThat(101, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.02)));
            %       testCase.assumeThat([101, 105], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance([2, 10]) & RelativeTolerance([0.02, 0.1])));
            %
            %       % Failing qualifications
            %       testCase.assertThat(102, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.01)));
            %       testCase.fatalAssertThat([101, 105], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance(2) & RelativeTolerance(0.02)));
            
            import matlab.unittest.constraints.AndTolerance;
            
            tolerance = AndTolerance(tolerance1, tolerance2);
        end
        
        function tolerance = or(tolerance1, tolerance2)
            % or - the logical element-wise disjunction of a tolerance
            %
            %   or(tolerance1, tolerance2) returns a tolerance which is the
            %   boolean disjunction of tolerance1 and tolerance2. This is a
            %   means to specify that every element of the actual value
            %   should be equal to the expected value to within the
            %   tolerance specified by either tolerance1 or tolerance2. A
            %   qualification failure should be produced when both
            %   tolerance1 and tolerance2 are not satisfied for one or more
            %   elements of the values being compared.
            %
            %   Typically, the OR method is not called directly, but the
            %   MATLAB "|" operator is used to denote the disjunction of
            %   any two ElementwiseTolerance objects.
            %
            %   Examples:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       import matlab.unittest.TestCase;
            %
            %       % Create a TestCase for interactive use
            %       testCase = TestCase.forInteractiveUse;
            %
            %       % Simple passing qualification
            %       testCase.verifyThat(105, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(3) | RelativeTolerance(0.1)));
            %
            %       % The following qualification passes because the OR
            %       % operation is performed element-wise between the
            %       % actual and expected values being compared:
            %       testCase.assertThat([8, 104], IsEqualTo([10, 100], 'Within', ...
            %           AbsoluteTolerance(3) | RelativeTolerance(0.05)));
            %       % Note that the following would fail:
            %       testCase.assertThat([8, 104], ...
            %           IsEqualTo([10, 100], 'Within', AbsoluteTolerance(3)) | ...
            %           IsEqualTo([10, 100], 'Within', RelativeTolerance(0.05)));
            %
            %       % Failing qualifications
            %       testCase.fatalAssertThat(101, IsEqualTo(100, 'Within', ...
            %           AbsoluteTolerance(0.5) | RelativeTolerance(0)));
            %       testCase.assumeThat([101, 101], IsEqualTo([100, 100], 'Within', ...
            %           AbsoluteTolerance([2, 0.5]) | RelativeTolerance([0.02, 0.001])));
            
            import matlab.unittest.constraints.OrTolerance;
            
            tolerance = OrTolerance(tolerance1, tolerance2);
        end
    end
end


function mask = getValuesToCompareMask(actVal, expVal)
% Return a mask of indices that need to be considered for tolerances.
% Indices with matching Inf or NaN values do not need to be considered.

eqInfs = isinf(actVal) & isinf(expVal) & (sign(actVal) == sign(expVal));
eqNaNs = isnan(actVal) & isnan(expVal);
mask = ~(eqInfs | eqNaNs);
end


function bool = areSizesCompatible(tolSz, valSz)
if isequal(tolSz, [1,1])
    % Scalar tolerances are always compatible with any sized value
    bool = true;
    return;
end

% Fill in trailing dimensions
n = max(numel(tolSz), numel(valSz));
tolSz(end+1:n) = 1;
valSz(end+1:n) = 1;

% Implicit expansion also generally allows valSz == 1 to satisfy the
% requirements for a dimension, but that's not valid here. The
% actual/expected values don't expand to the tolerance's size.
bool = all(tolSz == valSz | tolSz == 1);
end

% LocalWords:  Elementwise Ns NIndices sz NMask unittest

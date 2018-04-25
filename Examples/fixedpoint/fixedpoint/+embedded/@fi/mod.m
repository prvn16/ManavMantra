function z = mod(x,y)
%MOD    Modulus after division for a fi object.
%   MOD(x,y) for a fi object uses the same definition as the built-in
%   MATLAB MOD function (see MOD for more details).
%
%   Data Type Propagation Rules:
%   For fixed-point and/or integer input arguments, the output data type is
%   computed using the aggregation of both input signedness, word lengths,
%   and fraction lengths. For floating-point input arguments, the output
%   data type is the same the inputs. See fixed.aggregateType.
%
%   Limitations/Assumptions:
%   The inputs x and y must be real arrays of the same size, or either can
%   be a real scalar. The combination of fixed-point and floating-point 
%   inputs is not supported.
%
%   Example:
%     a = fi(4.5*pi);
%     b = fi(2*pi);
%     c = mod(a,b) % returns pi/2
%
%   See also mod, fixed.aggregateType
    
%   Copyright 2011-2016 The MathWorks, Inc.

    if ( (isinteger(x) || (isfi(x) && isscalingbinarypoint(x))) && ...
         (isinteger(y) || (isfi(y) && isscalingbinarypoint(y))) )
        % BOTH input arguments are (either) binary-point scaled FI or INTEGER:
        % Treat both inputs as binary-point scaled. Note: includes scaled double.
        tAgg = fixed.aggregateType(x, y);
        if (tAgg.WordLength <= 32)
            % Call builtin MOD directly (input word lengths are small)
            % NOTE: Get dimensions and complexity checking in this call.
            z = embedded.fi(mod(double(x), double(y)), tAgg);
        else
            F = fimath('RoundingMethod','Floor',...
                       'OverflowAction','Wrap',...
                       'ProductMode','SpecifyPrecision',...
                       'ProductWordLength',tAgg.WordLength,...
                       'ProductFixedExponent',tAgg.FixedExponent,...
                       'ProductSlopeAdjustmentFactor',tAgg.SlopeAdjustmentFactor,...
                       'ProductBias',tAgg.Bias,...
                       'SumMode','SpecifyPrecision',...
                       'SumWordLength',tAgg.WordLength,...
                       'SumFixedExponent',tAgg.FixedExponent,...
                       'SumSlopeAdjustmentFactor',tAgg.SlopeAdjustmentFactor,...
                       'SumBias',tAgg.Bias);
            % Divide by zero is acceptable because mod(x,0)=x by definition, 
            % so turn off the divide-by-zero warning.
            wrn = warning('off','fixed:fi:divideByZero');
            % This implements the definition of mod(x,y) = x - floor(x./y) .* y
            % Fixed-point x./0 always returns a finite value, so x./0 .* 0 = 0 
            % and so the equation always works.
            x = setfimath(x,F);
            y = setfimath(y,F);
            z = removefimath(x - floor(divide(tAgg,x,y)) .* y);
            % Restore the warning state.
            warning(wrn);
        end
    elseif isfi(x) && isfi(y) && isfloat(x) && isfloat(y)
        % BOTH inputs are FI floating-point: call builtin MOD directly
        % NOTE: Get dimensions and complexity checking in this call.
        if isequal(numerictype(x), numerictype(y))
            if isdouble(x)
                z = embedded.fi(mod(double(x),double(y)), numerictype(x));
            else
                z = embedded.fi(mod(single(x),single(y)), numerictype(x));
            end
        else
            % Mixed FI double and FI single inputs (return FI double)
            z = embedded.fi(mod(double(x),double(y)), numerictype('double'));
        end
    elseif (isfi(x) && isfixed(x)) && (isa(y,'double') || isa(y,'single') || (isfi(y) && isfloat(y)))
        error(message('fixed:fi:fixedAndFloatInputArgs'));
    elseif (isfi(y) && isfixed(y)) && (isa(x,'double') || isa(x,'single') || (isfi(x) && isfloat(x)))
        error(message('fixed:fi:fixedAndFloatInputArgs'));
    else
        error(message('fixed:fi:invalidInputDataTypeCombination'));
    end
    z = removefimath(z);
end

% LocalWords:  Agg

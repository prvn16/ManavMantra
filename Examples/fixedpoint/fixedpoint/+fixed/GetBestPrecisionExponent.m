function bestPrecisionExponent = GetBestPrecisionExponent(values, totalBits, isSigned)
    %GETBESTPRECISIONEXPONENT returns the best exponent 
    % Values    is of class numeric
    % totalBits is the total bits available for a fixed-point data type
    % isSigned  is the sign of the data type for which the best precision is calculated
    
    % Copyright 2011-2016 The MathWorks, Inc.
	
    if all(values == 0) || any(isnan(values)) || any(isinf(values))
        bestPrecisionExponent = -1000;
    else
        inputNumericType = numerictype(isSigned, totalBits);
        bestPrecisionType = embedded.fi.GetBestPrecisionForMxArray(values, inputNumericType);
        bestPrecisionExponent = bestPrecisionType.FixedExponent;
    end
    
end


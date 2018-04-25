function fractionLength = GetBestPrecision( values, wordLength, isSigned )
    %GETBESTPRECISION Summary of this function goes here
    %   Detailed explanation goes here

%   Copyright 2016 The MathWorks, Inc.
    
    fractionLength = -1*fixed.GetBestPrecisionExponent(values, wordLength, isSigned);
    
end


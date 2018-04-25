function fixedMinWL = GetMinWordLength( RealWorldValues, FractionBits, IsSigned )
%GETMINWORDLENGTH Summary of this function goes here
%   Detailed explanation goes here

%   Copyright 2011-2016 The MathWorks, Inc.
if any(isinf(RealWorldValues))
    % no Inf support
    DAStudio.error('fixed:fi:unsupportedInfInput'); 
end

if any(isnan(RealWorldValues))
    % no NaN support
    DAStudio.error('fixed:fi:unsupportedNanInput'); 
end

if ~isvector(RealWorldValues)
    % handle vector input only
    DAStudio.error('fixed:fi:inputsNotNumericVectors', 'GetMinWordLength'); 
end

% consider the type with IL integer bits and FL fractional bits
if IsSigned %signed type
    % represent range -2^IL <= RealWorldValues <=2^IL - 2^(-FL)
    lower_representValue = min(RealWorldValues);
    upper_representValue = max(RealWorldValues);
    if lower_representValue < 0
        candidateIL_neg = ceil(log2(abs(lower_representValue)));
    else
        candidateIL_neg = NaN;
    end
    if upper_representValue > 0
        candidateIL_pos = ceil(log2(upper_representValue + 2^(-FractionBits)));
    else
        candidateIL_pos = NaN;
    end
    
    fixedMinIL = max(candidateIL_neg, candidateIL_pos);
    fixedMinWL = 1 + FractionBits + fixedMinIL;
    % if RealWorldValues are 0, then fixedMinWL = NaN. Handle signed cases
    % with 2 bit WL. 
    if isnan(fixedMinWL) || fixedMinWL <= 1 
        fixedMinWL = 2;
    end
else %unsigned type
    % represent range 0 <= RealWorldValues <=2^IL - 2^(-FL)
    % handles the possible negative real world values first
    nonNegRealWorldValues = max(RealWorldValues, zeros(size(RealWorldValues)));    
    candidateIL_pos = ceil(log2(nonNegRealWorldValues + 2^(-FractionBits)));
    fixedMinIL = max(max(candidateIL_pos), NaN);
    fixedMinWL = fixedMinIL + FractionBits;
    if fixedMinWL <= 0
        fixedMinWL = 1;
    end
end




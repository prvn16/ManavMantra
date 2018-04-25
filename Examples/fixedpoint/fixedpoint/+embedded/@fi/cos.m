function y = cos(u)
%COS    Cosine of argument in radians.
%   COS(X) is the cosine of the elements of X.

%   Copyright 2011-2012 The MathWorks, Inc.

persistent FI_SIN_COS_LUT;

% Input argument checking
if ~isreal(u) || isboolean(u)
    error(message('fixed:fi:realAndNumeric'));
end

if isfixed(u)
    if ~isscalingbinarypoint(u)
        error(message('fixed:fi:inputsMustBeFixPtBPSOrFloatSameDTMode'));
    end
    % Initialize the (static, constant) lookup table
    tblValsNT = numerictype(1,16,15);
    if isempty(FI_SIN_COS_LUT)
        % Pre-quantize the constant values to avoid overflow warnings
        initialValuePreQuantize = 1.0 - double(eps(fi(0,tblValsNT)));
        quarterCosDblFltPtVals  = ...
            [initialValuePreQuantize; (cos(2*pi*((1:63) ./ 256)))'];
        
        quarterCosDblFltFlipped = -flipud(quarterCosDblFltPtVals);
        halfCosWaveDblFltPtVals = ...
            [quarterCosDblFltPtVals; 0; quarterCosDblFltFlipped];

        fullCosWaveDblFltPtVals = ...
            [halfCosWaveDblFltPtVals; ...
            -halfCosWaveDblFltPtVals(2:127); ...
            cos(2*pi*255/256)];

        FI_SIN_COS_LUT = fi(fullCosWaveDblFltPtVals, tblValsNT);
    end

    y = fixed.internal.sin_cos_fi_lut_private(u, FI_SIN_COS_LUT);
    
elseif isdouble(u) || isscaleddouble(u)
    % Input is FI double
    y = fi(cos(double(u)), numerictype(u));
    
else
    % Input is FI single
    y = fi(cos(single(u)), numerictype(u));
    
end

y.fimath = []; %Cast away local fimath

end % function

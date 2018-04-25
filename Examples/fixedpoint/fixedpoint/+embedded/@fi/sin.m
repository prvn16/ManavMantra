function y = sin(u)
%SIN    Sine of argument in radians.
%   SIN(X) is the sine of the elements of X.

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
        quarterSinDblFltPtVals  = (sin(2*pi*((0:63) ./ 256)))';
        endpointQuantized_Plus1 = 1.0 - double(eps(embedded.fi(0,tblValsNT)));
        halfSinWaveDblFltPtVals = ...
            [quarterSinDblFltPtVals; ...
            endpointQuantized_Plus1; ...
            flipud(quarterSinDblFltPtVals(2:end))];

        fullSinWaveDblFltPtVals = ...
            [halfSinWaveDblFltPtVals; -halfSinWaveDblFltPtVals];

        FI_SIN_COS_LUT = embedded.fi(fullSinWaveDblFltPtVals, tblValsNT);
        FI_SIN_COS_LUT.fimath = [];
    end

    y = fixed.internal.sin_cos_fi_lut_private(u, FI_SIN_COS_LUT);
    
elseif isdouble(u) || isscaleddouble(u)
    % Input is FI double
    y = embedded.fi(sin(double(u)), numerictype(u));
    
else
    % Input is FI single
    y = embedded.fi(sin(single(u)), numerictype(u));
    
end

y.fimath = []; %Cast away local fimath

end % function

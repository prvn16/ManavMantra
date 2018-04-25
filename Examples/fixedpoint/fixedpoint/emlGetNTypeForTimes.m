function T = emlGetNTypeForTimes(Ta,Tb,Fa,Aisreal,Bisreal,maxWL)
%emlGetNTypeForTimes  Get numerictype for TIMES
%   T = emlGetNTypeForTimes(numerictype(A),numerictype(B),fimath(A),isreal(A),isreal(B),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A.*B).  An error is thrown if detected.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 1999-2012 The MathWorks, Inc.

narginchk(5,6);
if nargin < 6
    maxWL = uint32(128);
end

if ~isscaledtype(Tb)
    throwError = isslopebiasscaled(Ta) && ~strcmpi(Fa.ProductMode,'SpecifyPrecision');
elseif ~isscaledtype(Ta)
    throwError = isslopebiasscaled(Tb) && ~strcmpi(Fa.ProductMode,'SpecifyPrecision');
else
    throwError = (isslopebiasscaled(Ta) || isslopebiasscaled(Tb)) && ~strcmpi(Fa.ProductMode,'SpecifyPrecision');
end

if throwError
    T = Ta;
    if isempty(coder.target)
        error(message('fixed:fi:mathModeSlopeBiasNotDefined','Product'));
    else
        eml_invariant(false, eml_message('fixed:fi:mathModeSlopeBiasNotDefined','Product'));
    end
else
    T = embedded.fi.GetNumericTypeForTimes(Ta,Tb,Fa,Aisreal,Bisreal,int32(maxWL));
end

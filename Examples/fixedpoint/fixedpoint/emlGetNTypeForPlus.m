function Tplus = emlGetNTypeForPlus(Ta,Tb,Fa,maxWL)
%emlGetNTypeForPlus  Get numerictype for plus
%   T = emlGetNTypeForPlus(numerictype(A),numerictype(B),fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A+B).  An error is thrown if detected.

%   This is used as a private function for MATLAB code generation.
%
%   Copyright 1999-2012 The MathWorks, Inc.

narginchk(3,4);
if nargin < 4
    maxWL = uint32(128);
end

if ~isscaledtype(Tb)
    throwError = isslopebiasscaled(Ta) && ~strcmpi(Fa.SumMode,'SpecifyPrecision');
elseif ~isscaledtype(Ta)
    throwError = isslopebiasscaled(Tb) && ~strcmpi(Fa.SumMode,'SpecifyPrecision');
else
    throwError = (isslopebiasscaled(Ta) || isslopebiasscaled(Tb)) && ~strcmpi(Fa.SumMode,'SpecifyPrecision');
end

if throwError
    Tplus = Ta;
    if isempty(coder.target)
        error(message('fixed:fi:mathModeSlopeBiasNotDefined','Sum'));
    else
        eml_invariant(false, eml_message('fixed:fi:mathModeSlopeBiasNotDefined','Sum'));
    end
else
    Tplus = embedded.fi.GetNumericTypeForPlus(Ta,Tb,Fa,int32(maxWL));    
end

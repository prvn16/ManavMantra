function T = emlGetNTypeForMTimes(Ta,Tb,Fa,Aisreal,Bisreal,p,isConstSize,maxWL,callerName)
%emlGetNTypeForMTimes  Get numerictype for matrix times (MTIMES)
%   T = emlGetNTypeForMTimes(numerictype(A),numerictype(B),fimath(A),isreal(A),isreal(B),size(A,2),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(A*B). If an error is detected, then an error is thrown.

%   This is used as a private function for MATLAB.
%
%   Copyright 1999-2012 The MathWorks, Inc.

narginchk(6,9);
if nargin < 9
    callerName = 'MTIMES';
    if nargin < 8
        maxWL = uint32(128);
        if nargin < 7
            isConstSize = true;
        end
    end
end

if ~isConstSize && (~strcmpi(Fa.SumMode,'SpecifyPrecision') && ~strcmpi(Fa.SumMode,'KeepLSB'))
    T = numerictype; %dummy output numerictype
    if isempty(coder.target)
        error(message('fixed:numerictype:codeGenSumModeNotSupported', callerName));
    else
        eml_invariant(false, eml_message('fixed:numerictype:codeGenSumModeNotSupported', callerName));
    end
else
    T = embedded.fi.GetNumericTypeForMatrixTimes(Ta,Tb,Fa,Aisreal,Bisreal,double(p),int32(maxWL));    
end

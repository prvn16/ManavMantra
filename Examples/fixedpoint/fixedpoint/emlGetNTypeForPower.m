function Tpower = emlGetNTypeForPower(a,k,Fa,maxWL)
%emlGetNTypeForPower Get numerictype for POWER
%   T=emlGetNTypeForPower(A,K,fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(POWER(A,K)). An error is thrown if detected.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 2009-2012 The MathWorks, Inc.

narginchk(3,4);
if nargin == 3
    maxWL = uint32(128);
end
a1 = fi(a, Fa);
    
y = a1.^k;
Tpower = numerictype(y);

if (Tpower.WordLength > maxWL)
    if isempty(coder.target)
        error(message('fixed:fi:maxWordLengthExceeded',Tpower.WordLength,maxWL));
    else
        eml_invariant(false, eml_message('fixed:fi:maxWordLengthExceeded',Tpower.WordLength,maxWL));
    end
end

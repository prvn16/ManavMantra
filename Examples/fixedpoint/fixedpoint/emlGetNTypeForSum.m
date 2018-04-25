function Tsum = emlGetNTypeForSum(Ta,Fa,sizeA,isConstSize,sumDim,maxWL)
%emlGetNTypeForSum  Get numerictype for SUM
%   T = emlGetNTypeForSum(numerictype(A),fimath(A),size(A),isConstSize,SUMDIM,maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(sum(A,SUMDIM)).  An error is thrown if detected.
%
%   isConstSize is false if the caller is a MATLAB library function and the
%   sizes of the inputs are not known at compile-time; it is true otherwise.

%   This is used as a private function for MATLAB.
%
%   Copyright 1999-2012 The MathWorks, Inc.

narginchk(3,6);
if nargin < 6
    maxWL = uint32(128);
    if nargin < 5
        sumDim = 2;
        if nargin < 4
            isConstSize = true; 
        end
    end
end

if ~isConstSize && (~strcmpi(Fa.SumMode,'SpecifyPrecision') && ~strcmpi(Fa.SumMode,'KeepLSB'))
    Tsum = numerictype; %dummy output numerictype
    if isempty(coder.target)
        error(message('fixed:numerictype:codeGenSumModeNotSupported','SUM'));
    else
        eml_invariant(false, eml_message('fixed:numerictype:codeGenSumModeNotSupported','SUM'));
    end
else
    Tsum = embedded.fi.GetNumericTypeForSum(Ta,Fa,double(sizeA),double(sumDim),int32(maxWL));    
end

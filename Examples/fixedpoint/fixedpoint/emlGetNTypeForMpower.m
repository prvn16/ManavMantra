function Tpower = emlGetNTypeForMpower(a,szA,k,Fa,maxWL)
%emlGetNTypeForMpower Get numerictype for MPOWER
%   Tpower = emlGetNTypeForMpower(A,K,fimath(A),maximumWordLength)
%   returns the numerictype object T that would be produced by
%   T=numerictype(MPOWER(A,K)). An error is thrown if detected.

%   This is used as a private function for Embedded MATLAB.
%
%   Copyright 2009-2013 The MathWorks, Inc.

narginchk(4,5);
if nargin == 4
    maxWL = uint32(128);
end
    
k = double(k);
smode = Fa.SumMode;
pmode = Fa.ProductMode;
swl = Fa.SumWordLength;
sfl = Fa.SumFractionLength;
ta = numerictype(a);
if strcmpi(smode, 'SpecifyPrecision')
    Tpower = numerictype(numerictype(a.Signed, swl, sfl),'DataType',ta.DataType);
else
    ar = real(a);
    tmp = ar.^k;
    issmodefp = strcmpi(smode, 'FullPrecision');
    issmodekmsb = strcmpi(smode, 'KeepMSB');
    if (issmodefp||issmodekmsb)
        ispmodesp = strcmpi(pmode, 'SpecifyPrecision');
        ispmodekmsb = strcmpi(pmode, 'KeepMSB');
        ispmodeklsb = strcmpi(pmode, 'KeepLSB');
        if isreal(a)
            nb = ceil(log2(szA(1)));
        else
            nb = ceil(log2(szA(1)+1));
        end
        if issmodefp                                  
            if (ispmodesp || ispmodeklsb)
                Tpower = numerictype(numerictype(a.Signed, tmp.WordLength + nb, ...
                                                 tmp.FractionLength),'DataType',ta.DataType);
            elseif ispmodekmsb
                Tpower = numerictype(numerictype(a.Signed, tmp.WordLength + nb,...
                                                 tmp.FractionLength-(k-2)*nb),...
                                     'DataType',ta.DataType);
            else                     
                Tpower = numerictype(numerictype(a.Signed, tmp.WordLength + (k-1)*nb,...
                                                 tmp.FractionLength),'DataType',ta.DataType);
            end
        else
            if ispmodesp
                Tpower = numerictype(numerictype(a.Signed, swl, swl - tmp.WordLength + ...
                                                 tmp.FractionLength - nb),'DataType',ta.DataType);
            else                     
                Tpower = numerictype(numerictype(a.Signed, swl, swl - tmp.WordLength + ...
                                                 tmp.FractionLength - (k-1)*nb),'DataType',ta.DataType);
            end
        end
    else
        Tpower = numerictype(numerictype(a.Signed, swl, tmp.FractionLength),'DataType',ta.DataType);
    end
end

if (Tpower.WordLength > maxWL)
    if isempty(coder.target)
        error(message('fixed:fi:maxWordLengthExceeded',Tpower.WordLength,maxWL));
    else
        eml_invariant(false, eml_message('fixed:fi:maxWordLengthExceeded',Tpower.WordLength,maxWL));
    end
end

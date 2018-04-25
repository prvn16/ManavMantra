function [IntArray,varargout] = fi2sim(A)
%FI2SIM Simulink integer array to FI object
%   [IntArray, NumericType]                                              = FI2SIM(A)
%   [IntArray, Signed, WordLength, FractionLength]                       = FI2SIM(A)
%   [IntArray, Signed, WordLength, Slope, Bias]                          = FI2SIM(A)
%   [IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias] = FI2SIM(A)
%
%   Returns stored-integer data in integer array IntArray and numeric
%   attributes from FI object A.
%
%   FI2SIM is the inverse of SIM2FI.
%
%   See also FI, EMBEDDED.FI/SIM2FI

%   Copyright 2003-2012 The MathWorks, Inc.
%     

error(nargoutchk(0,6,nargout,'struct'));

if A.WordLength > 128
  error(message('fixed:fi:simulinkData128Bits'));
end

IntArray = simulinkarray(A);

switch nargout
  case 2
    % [IntArray, NumericType] = FI2SIM(A)
    varargout{1} = numerictype(A);
  case 3
    % [IntArray, Signed, WordLength] = FI2SIM(A)
    varargout{1} = A.Signed;
    varargout{2} = A.WordLength;
  case 4
    % [IntArray, Signed, WordLength, FractionLength] = FI2SIM(A)
    varargout{1} = A.Signed;
    varargout{2} = A.WordLength;
    varargout{3} = A.FractionLength;
  case 5
    % [IntArray, Signed, WordLength, Slope, Bias] = FI2SIM(A)
    varargout{1} = A.Signed;
    varargout{2} = A.WordLength;
    varargout{3} = A.Slope;
    varargout{4} = A.Bias;
  case 6
    % [IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias] = FI2SIM(A)
    varargout{1} = A.Signed;
    varargout{2} = A.WordLength;
    varargout{3} = A.SlopeAdjustmentFactor;
    varargout{4} = A.FixedExponent;
    varargout{5} = A.Bias;
end

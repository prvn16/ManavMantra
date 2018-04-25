function u = eps(T) %#codegen
% EPS Quantized relative accuracy for an embedded.numerictype object
%
%     See also embedded.fi/eps, embedded.quantizer/eps
%
%     Copyright 2017 The MathWorks, Inc.

  u = eps(fi(1,T));
end
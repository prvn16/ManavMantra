function u = lsb(T) %#codegen
%  LSB Scaling of least significant bit of embedded.numerictype object 
%     U = lsb(A) returns the scaling of the least significant bit of an
%     embedded.numerictype object. The result is equivalent to the result
%     given by the EPS function.
%  
%     See also embedded.numerictype/eps, embedded.fi/lsb
%
%     Copyright 2017 The MathWorks, Inc.

  u = lsb(fi(1,T));
end
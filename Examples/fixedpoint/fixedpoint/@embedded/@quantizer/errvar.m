function v = errvar(q)
%ERRVAR Variance of the quantization error
%   ERRVAR(Q) returns the variance of a uniformly distributed random
%   quantization error that would arise from quantizing a signal by quantizer Q.
%
%   Note that the results will be not be exact if the signal precision is
%   close to the precision of the quantizer.
%
%   Example:
%     q = quantizer;
%     v = errvar(q)
%     
%     % Compare to the sample variance from a Monte Carlo experiment:
%     r = realmax(q);
%     u = 2*r*rand(1000,1)-r;  % Original signal
%     y = quantize(q,u);       % Quantized signal
%     e = y - u;               % Error
%     v_est = var(e)           % Estimate of the error variance
%
%   See also EMBEDDED.QUANTIZER/ERRMEAN, EMBEDDED.QUANTIZER/ERRPDF
  
%   See Dietrich Schlichtharle, Digital Filters, Springer, 2000, p. 236ff for a
%   discussion of a correction factor for quantizing from one fixed-point number
%   to another.

%   Thomas A. Bryan, 6 August 2001
%   Copyright 1999-2006 The MathWorks, Inc.
  
switch q.roundmode
 case 'fix'
  v = (eps(q).^2)/3;
 otherwise
  v = (eps(q).^2)/12;
end

function m = errmean(q)
%ERRMEAN Mean of the quantization error
%   ERRMEAN(Q) returns the mean of a uniformly distributed random quantization
%   error that would arise from quantizing a signal by quantizer Q.
%
%   Note that the results will be not be exact if the signal precision is
%   close to the precision of the quantizer.
%
%   Example:
%     q = quantizer;
%     m = errmean(q)
%     
%     % Compare to the sample mean from a Monte Carlo experiment:
%     r = realmax(q);
%     u = 2*r*rand(1000,1)-r;  % Original signal
%     y = quantize(q,u);       % Quantized signal
%     e = y - u;               % Error
%     m_est = mean(e)          % Estimate of the error mean
%
%   See also EMBEDDED.QUANTIZER/ERRPDF, EMBEDDED.QUANTIZER/ERRVAR
  
%   See Dietrich Schlichtharle, Digital Filters, Springer, 2000, p. 236ff for a
%   discussion of a correction factor for quantizing from one fixed-point number
%   to another.

%   Thomas A. Bryan, 6 August 2001
%   Copyright 1999-2006 The MathWorks, Inc.

switch q.roundmode
case 'floor'
  m = -eps(q)/2;
case 'ceil'
  m =  eps(q)/2;
otherwise
  m = 0;
end

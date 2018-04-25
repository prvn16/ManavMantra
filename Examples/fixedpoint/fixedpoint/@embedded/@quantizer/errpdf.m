function [f,x] = errpdf(q,x)
%ERRPDF Probability density function of the quantization error
%   [F,X] = ERRPDF(Q) returns the probability density function F evaluated at
%   the values in X of a uniformly distributed random quantization error that
%   would arise from quantizing a signal by quantizer Q.
%
%   F = ERRPDF(Q,X) returns the probability density function F evaluated at
%   the values in vector X.
%
%   Note that the results will be not be exact if the signal precision is
%   close to the precision of the quantizer.
%
%   Example:
%     q = quantizer('nearest',[4 3]);
%     [f,x] = errpdf(q);
%     subplot(211)
%     plot(x,f)
%     title('Computed PDF of the quantization error.')
%     
%     % Compare to the sample pdf from a Monte Carlo experiment:
%     r = realmax(q);
%     u = 2*r*rand(10000,1)-r;  % Original signal
%     y = quantize(q,u);        % Quantized signal
%     e = y - u;                % Error
%     subplot(212)
%     hist(e,20);set(gca,'xlim',[min(x) max(x)])
%     title('Estimate of the PDF of the quantization error.')
%
%   See also EMBEDDED.QUANTIZER/ERRMEAN, EMBEDDED.QUANTIZER/ERRVAR
  
%   Thomas A. Bryan, 6 August 2001
%   Copyright 1999-2011 The MathWorks, Inc.
%   
  
e = double(eps(q));
if nargin<2, x=[]; end
if isempty(x), x = linspace(-2*e,2*e,128); end

switch q.roundmode
  case {'fix','zero'}
    f = (-e<x & x<e)/(2*e);
  case 'floor'
    f = (-e<x & x<=0)/e;
  case {'ceil','ceiling'}
    f = (0<=x & x<e)/e;
  case 'convergent'
    f = (-e/2<=x & x<=e/2)/e;
  case 'nearest' 
    f = (-e/2<x & x<=e/2)/e;
  case 'round'
    f = (-e/2<=x & x<=e/2)/e;
  otherwise
    error(message('fixed:quantizer:errpdf_invalidRoundMode'));
end
  

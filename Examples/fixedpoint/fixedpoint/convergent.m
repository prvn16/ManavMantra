function y = convergent(x)
%CONVERGENT Convergent rounding.
%   CONVERGENT(X) rounds the elements of X to the nearest integer,
%   except in a tie, then round to the nearest even integer.
%
%   CONVERGENT, NEAREST, and ROUND only differ in the way they treat
%   values whose fractional part is 0.5.
%
%   In CONVERGENT, the ties are rounded to the nearest even integer. 
%   In NEAREST, the ties are rounded up.
%   In ROUND, every tie is rounded up in absolute value.
%
%   Example:
%
%       x=[-3.5:3.5]';
%       [x convergent(x) nearest(x) round(x)]
%
%   See also FLOOR, CEIL, FIX, NEAREST, ROUND, 
%   QUANTIZER/ROUND, QUANTIZER/QUANTIZE. 

%   Reference:
%     Phil Lapsley, Jeff Bier, Amit Shoham, Edward A. Lee, DSP Processor
%     Fundamentals, IEEE Press, 1997, ISBN 0-7803-3405-1
%
%   Thomas A. Bryan
%   Copyright 1999-2007 The MathWorks, Inc.

if ~isnumeric(x)
    error(message('fixed:fi:InvalidInputNotNumeric'));
elseif isinteger(x)
    y = x;
else
    issngl = isa(x,'single');
    x = double(x+0); % To force it to double

    % Quantize to integers (fractionlength = 0) with convergent rounding.
    % Skip quantizing everything bigger than the largest "flint" (floating-point
    % integer), which is 2^53, because those numbers are always integers anyway.
    q = quantizer('fixed',[53 0],'convergent');
    if isreal(x)
        y = x;
        L = abs(x)<2^53;
        y(L) = quantize(q,x(L));
    else
        % Need to do real and imaginary separately because > is not defined for
        % complex numbers.
        xr = real(x); xi = imag(x);
        yr = xr;  yi = xi;
        L = abs(xr)<2^53;
        yr(L) = quantize(q,xr(L));
        L = abs(xi)<2^53;
        yi(L) = quantize(q,xi(L));
        y = complex(yr,yi);
    end

    if issngl
        y = single(y);
    end
end


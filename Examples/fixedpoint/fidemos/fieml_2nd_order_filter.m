function y = fieml_2nd_order_filter(num, den, u)%#codegen
%FIEML_2ND_ORDER_FILTER  Fixed-point second-order filter.
%    Y = FIEML_2ND_ORDER_FILTER(B,A,X) filters data X with second-order 
%    filter coefficients B and A.
%

%   Copyright 2005-2010 The MathWorks, Inc.

% Persistent state variables
persistent zx zy; 

% Initialize the output, accumulator, and states
%
if isfi(u)
    % The input is fixed-point.  Compute in fixed-point
    
    % Create numerictypes with 16 bit word-length for the coefficients
    Tb = numerictype(1,16,15); Ta = numerictype(1,16,14);
    
    % Create numerictypes with 16 bit word-length for output and 40 bit 
    % word-length for accumulator; specify scaling as determined from 
    % logged data (see fi_datatype_override_demo.m)    
    Ty   = numerictype(1, 16, 15);
    Tacc = numerictype(1, 40, 38);
    
    b = fi(num,Tb);
    a = fi(den,Ta);    
    x = u;
    y   = fi(zeros(size(x)), Ty);
    acc = fi(0, Tacc);
    if isempty(zx) || isempty(zy)
        % Initialize states
        zx = fi(zeros(2,1), numerictype(x));
        zy = fi(zeros(2,1), numerictype(y));
    end
else
    % The input is not fixed-point.  Compute in built-in double-precision
    % floating-point.
    b   = double(num);
    a   = double(den);
    x   = double(u);
    y   = zeros(size(x));
    acc = 0;
    if isempty(zx) || isempty(zy)
        % Initialize states
        zx = zeros(2,1);
        zy = zeros(2,1);
    end
end

% Filter loop:
% y(k) = b(1)*x(k) + b(2)*x(k-1) + b(3)*x(k-2) 
%                  - a(2)*y(k-1) - a(3)*y(k-2)
for k = 1:length(x)
    acc(1) = b(1)*x(k);
    acc(1) = acc + b(2)*zx(1);  % acc += b(2)*x(k-1)
    acc(1) = acc + b(3)*zx(2);  % acc += b(3)*x(k-2)
    acc(1) = acc - a(2)*zy(1);  % acc -= a(2)*y(k-1)
    acc(1) = acc - a(3)*zy(2);  % acc -= a(3)*y(k-2)
    y(k)   = acc;
    % State update
    zx(2)  = zx(1); zx(1) = x(k);
    zy(2)  = zy(1); zy(1) = y(k);
end


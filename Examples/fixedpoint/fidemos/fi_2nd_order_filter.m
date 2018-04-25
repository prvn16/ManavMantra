function [y, acc] = fi_2nd_order_filter(b,a,x,Ty,Tacc,resetStates)
%FI_2ND_ORDER_FILTER  Fixed-point second-order filter.
%    [Y, ACC] = FI_2ND_ORDER_FILTER(B,A,X,Ty,Tacc,ResetStates)
%    filters data X with second-order filter coefficients B and A.
%    If X is fixed point, then this function runs in fixed point,
%    using Ty as the NUMERICTYPE of output Y, and Tacc as the
%    NUMERICTYPE of the accumulator ACC.  If ResetStates is missing,
%    or TRUE, then the states are reset.
%
%    Note: A single, global fimath is assumed to apply to all
%    operations inside this function. You may use globalfimath to set
%    up this fimath.
%
%    See FI_DATATYPE_OVERRIDE_DEMO for example of use.

%    Copyright 2005-2012 The MathWorks, Inc.
%#codegen

% Persistent state variables
persistent zx zy 

% Initialize the output, accumulator, and states
if nargin<4, Ty=[]; end
if nargin<5, Tacc=[]; end
if nargin<6, resetStates = true; end
if isfi(x)
    % The input is fixed point.  Compute in fixed point
    if isempty(Ty),   Ty   = numerictype(x); end
    if isempty(Tacc), Tacc = numerictype(x); end
    y   = fi(zeros(size(x)), Ty);
    acc = fi(0, Tacc);
    if isempty(zx) || isempty(zy) || resetStates
        % Initialize states
        zx = fi(zeros(2,1), numerictype(x));
        zy = fi(zeros(2,1), numerictype(y));
    end
else
    % The input is not fixed point.  Compute in built-in double-precision
    % floating-point.
    b   = double(b);
    a   = double(a);
    x   = double(x);
    y   = zeros(size(x));
    acc = 0;
    if isempty(zx) || isempty(zy) || resetStates
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
    acc(1) = acc + b(2)*zx(1);
    acc(1) = acc + b(3)*zx(2);
    acc(1) = acc - a(2)*zy(1);
    acc(1) = acc - a(3)*zy(2);
    y(k)   = acc;
    % State update
    zx(2)  = zx(1); zx(1) = x(k);
    zy(2)  = zy(1); zy(1) = y(k);
end


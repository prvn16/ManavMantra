function [xd,cxd,lxd,thrs] = wden(in1,in2,in3,in4,in5,in6,in7)
%MATLAB Code Generation Library Function

%   Limitations:
%   * Dynamic memory allocation will probably be required.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(6,7);
coder.internal.prefer_const(in2,in3,in4,in5,in6);
if nargin == 6
    tptr = in2;
    sorh = in3;
    scal = in4;
    n = in5;
    w = in6;
    x = in1;
else
    coder.internal.prefer_const(in7);
    tptr = in3;
    sorh = in4;
    scal = in5;
    n = in6;
    w = in7;
    c = in1;
    l = in2;
end
coder.internal.assert(ischar(tptr), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(coder.internal.isConst(tptr), ...
    'Wavelet:codegeneration:TptrMustBeConstant');
coder.internal.assert(ischar(sorh), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(ischar(scal), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(isnumeric(n) && isscalar(n) && ...
    n >= 1 && n == floor(n), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(ischar(w), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
if nargin == 6
    % Adding MODWT denoising
    if strcmpi(tptr,'modwtsqtwolog')
        coder.internal.assert(nargout <= 3, ...
            'Wavelet:modwt:TooManyOutputs');
        [xd,cxd,thrs] = modwtdenoise1D(x,w,n,sorh,scal);
        lxd = thrs;
        return
    end
    % Wavelet decomposition of x.
    [c,l] = wavedec(x,n,w);
end
SCALONE = strcmp(scal,'one');
SCALSLN = strcmp(scal,'sln');
SCALMLN = strcmp(scal,'mln');
coder.internal.assert(SCALONE || SCALSLN || SCALMLN, ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
% Threshold rescaling coefficients.
if SCALONE
    s = ones(1,n);
elseif SCALSLN
    s = ones(1,n)*wnoisest(c,l,1);
else % SCALMLN
    s = wnoisest(c,l,1:n);
end
% Wavelet coefficients thresholding.
first = coder.internal.indexInt(cumsum(l(1:end-2))) + 1;
first = flip(first);
last = coder.internal.indexInt(l(end-1:-1:2)) + first - 1;
cxd = c;
lxd = l;

% Return thr consistently as a row vector for row vector coefficients
% or column for column vector coefficients

if coder.internal.isConst(iscolumn(c)) && iscolumn(c) 
  thrs = zeros(n,1); 
else 
  thrs = zeros(1,n); 
end

if strcmp(tptr,'sqtwolog') || strcmp(tptr,'minimaxi')
    thr = thselect(c,tptr);
    for k = 1:n
        thrs(k) = thr*s(k); % rescaled threshold.
        for j = first(k):last(k)
            cxd(j) = wthresh(c(j),sorh,thrs(k)); % thresholding or shrinking.
        end
    end
else
    for k = 1:n
        flk = first(k):last(k);
        if s(k) < sqrt(eps)*max(c(flk))
            thr = 0;
        else
            thr = thselect(c(flk)/s(k),tptr);
        end
        thrs(k) = thr*s(k); % rescaled threshold.
        cxd(flk) = wthresh(c(flk),sorh,thrs(k)); % thresholding or shrinking.
    end
end
% Wavelet reconstruction of xd.
xd = waverec(cxd,lxd,w);

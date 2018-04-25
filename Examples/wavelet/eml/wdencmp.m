function [xc,cxc,lxc,perf0,perfl2] = wdencmp(o,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,inf); % Make sure o is supplied before referencing it.
coder.internal.prefer_const(o,varargin);
% Check arguments and set problem dimension.
GBL = strcmp(o,'gbl');
LVD = strcmp(o,'lvd');
coder.internal.assert(GBL || LVD, ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
if GBL
    minIn = 7;
    maxIn = 8;
else
    minIn = 6;
    maxIn = 7;
end
narginchk(minIn,maxIn);
coder.internal.assert(nargout ~= 2, ...
    'Wavelet:FunctionOutput:Invalid_ArgNum');
if nargin == minIn
    x = varargin{1}; 
    indarg = 2;
    if coder.internal.isConst(isvector(x)) && isvector(x)
        dim = 1;
    else
        dim = 2; 
    end
else
    c = varargin{1}; 
    lxc = varargin{2}; 
    indarg = 3;
    if coder.internal.isConst(isvector(lxc)) && isvector(lxc)
        dim = 1;
    else
        dim = 2;
    end
end
% Get Inputs
w    = varargin{indarg};
n    = varargin{indarg+1};
thr  = varargin{indarg+2};
sorh = varargin{indarg+3};
if GBL
    keepapp = varargin{indarg+4}; 
end
coder.internal.assert(ischar(w), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(isnumeric(n) && isscalar(n) && ...
    n >= 1 && floor(n) == n, ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(allgt0(thr), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(ischar(sorh), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
% Wavelet decomposition of x (if not given).
if nargin == minIn
    if dim == 1
        [c,lxc] = wavedec(x,n,w);
    else
        [c,lxc] = wavedec2(x,n,w);
    end
end
% Wavelet coefficients thresholding.
if GBL
    if keepapp
        % keep approximation.
        cxc = c;
        if dim == 1
            % inddet = lxc(1)+1:length(c);
            first = coder.internal.indexInt(lxc(1) + 1);
        else
            % inddet = prod(lxc(1,:))+1:length(c); 
            first = coder.internal.indexInt(prod(lxc(1,:)) + 1);
        end
        last = coder.internal.indexInt(length(c));
        % threshold detail coefficients.
        % cxc(inddet) = wthresh(c(inddet),sorh,thr);
        for k = first:last
            cxc(k) = wthresh(c(k),sorh,thr);
        end
    else 
        % threshold all coefficients.
        cxc = wthresh(c,sorh,thr);
    end
else
    if dim == 1
        cxc = wthcoef('t',c,lxc,1:n,thr,sorh);
    else
        cxc = wthcoef2('h',c,lxc,1:n,thr(1,:),sorh);
        cxc = wthcoef2('d',cxc,lxc,1:n,thr(2,:),sorh);
        cxc = wthcoef2('v',cxc,lxc,1:n,thr(3,:),sorh);
    end
end
% Wavelet reconstruction of xd.
if dim == 1
    xc = waverec(cxc,lxc,w);
else
    xc = waverec2(cxc,lxc,w);
end
if nargout >= 4
    % Compute compression score.
    nzeros = 0;
    ncxc = length(cxc);
    for k = 1:ncxc
        if cxc(k) == 0
            nzeros = nzeros + 1;
        end
    end
    perf0 = 100*(nzeros/ncxc);
    if nargout >= 5
        % Compute L^2 recovery score.
        nc = norm(c);
        if nc < eps
            perfl2 = 100;
        else
            perfl2 = 100*((norm(cxc)/nc)^2);
        end
    end
end

%--------------------------------------------------------------------------

function p = allgt0(x)
% Returns p = all(x(:) > 0).
p = isnumeric(x);
if p
    for k = 1:numel(x)
        if ~(x(k) > 0)
            p = false;
        end
    end
end

%--------------------------------------------------------------------------

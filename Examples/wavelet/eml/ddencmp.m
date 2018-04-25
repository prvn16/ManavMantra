function [thr,sorh,keepapp,crit] = ddencmp(dorc,worwp,x)
% MATLAB Code Generation Library Function
%
%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(3,3);
coder.internal.prefer_const(dorc,worwp);

WV = isequal(worwp,'wv');
WP = isequal(worwp,'wp');
DEN = isequal(dorc,'den');

% Check arguments.
coder.internal.assert(nargout <= 3 || ~WV, ...
    'Wavelet:FunctionOutput:TooMany_ArgNum');
coder.internal.assert(WV || WP, ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');

% Set thr value.
if DEN
    n = numel(x);
    if WV
        thr = sqrt(2*log(n)); % wavelets.
        normaliz = calcNormaliz(x,false);
        thr = thr*normaliz/0.6745;
    else
        thr = sqrt(2*log(n*log(n)/log(2))); % wavelet packets.
    end
else
    thr = calcNormaliz(x,true);
end

% Set sorh value.
if DEN && WV
    sorh = 's'; 
else
    sorh = 'h'; 
end

% Set keepapp default value.
keepapp = 1;

% Set crit value. The assignment will automatically be eliminated in the
% generated code if nargout < 4.
if DEN
    crit = 'sure';
else
    crit = 'threshold';
end

%--------------------------------------------------------------------------

function normaliz = calcNormaliz(x,CMP)
coder.internal.prefer_const(CMP);
if isvector(x)
    [c1,l1] = wavedec(x(:),1,'db1');
    % c2 = c1(l1(1)+1:end);
    offset = coder.internal.indexInt(l1(1));
    lenc2 = coder.internal.indexInt(length(c1)) - offset;
    c2 = coder.nullcopy(zeros(1,lenc2,'like',c1));
    for k = 1:lenc2
        c2(k) = c1(offset + k);
    end
    normaliz = median(abs(c2));
    % if normaliz=0 in compression, kill the lowest coefs.
    if CMP && normaliz == 0
        normaliz = 0.05*max(abs(c2));
    end
else
    [c3,l3] = wavedec2(x,1,'db1');
    % c4 = c3(prod(l3(1,:))+1:end);
    offset = coder.internal.indexInt(prod(l3(1,:)));
    lenc4 = coder.internal.indexInt(numel(c3)) - offset;
    c4 = coder.nullcopy(zeros(1,lenc4,'like',c3));
    for k = 1:lenc4
        c4(k) = c3(offset + k);
    end
    normaliz = median(abs(c4));
    % if normaliz=0 in compression, kill the lowest coefs.
    if CMP && normaliz == 0
        normaliz = 0.05*max(abs(c4));
    end
end

%--------------------------------------------------------------------------

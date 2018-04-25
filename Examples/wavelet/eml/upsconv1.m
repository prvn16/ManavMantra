function y = upsconv1(x,f,s,dwtARG1,dwtARG2)
% MATLAB Code Generation Library Function
%
%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(3,5);
coder.internal.prefer_const(s);

ONE = coder.internal.indexInt(1);

% Check arguments for Extension and Shift.
if nargin == 3
    perFLAG  = false;
    dwtSHIFT = false;
elseif nargin == 4
    % Arg4 is a STRUCT
    coder.internal.prefer_const(dwtARG1);
    perFLAG  = isequal(dwtARG1.extMode,'per');
    shiftInput = coder.internal.indexInt(dwtARG1.shift1D);
    dwtSHIFT = eml_bitand(shiftInput,ONE) == ONE;
else % if nargin == 5
    coder.internal.prefer_const(dwtARG1,dwtARG2);
    perFLAG  = isequal(dwtARG1,'per');
    shiftInput = coder.internal.indexInt(dwtARG2);
    dwtSHIFT = eml_bitand(shiftInput,ONE) == ONE;
end

% Special case.
if isempty(x)
    y = zeros('like',coder.internal.scalarEg(x,f));
    return
end

% Define Length.
lx = 2*coder.internal.indexInt(length(x));
lf = coder.internal.indexInt(length(f));
if coder.internal.isConst(isscalar(s)) && isscalar(s)
    s1 = coder.internal.indexInt(s);
elseif perFLAG
    s1 = lx;
else
    s1 = lx - lf + 2;
end

% Compute Upsampling and Convolution.
if perFLAG
    lfd2 = eml_rshift(lf,ONE); % lf/2 rounded down
    y0 = dyadup(x,false,true); % undocumented "force even" syntax
    y1 = wextend('1D','per',y0,lfd2);
    y2 = wconv1(y1,f);
    % Using coder.nullcopy this way allocates y with s elements with the
    % correct orientation without needing to worry about whether it is a
    % row vector or column vector.
    y = coder.nullcopy(y2(1:s1));
    if dwtSHIFT
        for k = ONE:s1-1
            y(k) = y2(lf + k);
        end
        y(s1) = y2(lf);
    else
        for k = ONE:s1
            y(k) = y2(lf + k - 1);
        end
    end
else
    y1 = wconv1(dyadup(x,false),f);
    y = wkeep1(y1,s1,'c',dwtSHIFT);
end

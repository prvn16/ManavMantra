function [a,d] = dwt(x,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

ONE = coder.internal.indexInt(1);
TWO = coder.internal.indexInt(2);
THREE = coder.internal.indexInt(3);
coder.internal.prefer_const(varargin);

% Check arguments.
narginchk(2,7);
if ischar(varargin{1})
    [Lo_D,Hi_D] = wfiltersConst(varargin{1},'d');
    next = TWO;
else
    Lo_D = varargin{1}; 
    Hi_D = varargin{2};  
    next = THREE;
end

% Check arguments for Extension and Shift.
[dwtEXTM_default,shift_default] = defaultDWTExtModeAndShift(1);
parms = struct( ...
    'mode',uint32(0), ...
    'shift',uint32(0));
poptions = struct( ...
    'CaseSensitivity',true, ...
    'PartialMatching','none', ...
    'StructExpand',false, ...
    'IgnoreNulls',false);
pstruct = coder.internal.parseParameterInputs(parms,poptions, ...
    varargin{next:end});
dwtEXTM = coder.internal.getParameterValue(pstruct.mode, ...
    dwtEXTM_default,varargin{next:end});
shift = coder.internal.indexInt(coder.internal.getParameterValue( ...
    pstruct.shift,shift_default,varargin{next:end}));

% Compute sizes and shape.
lf = coder.internal.indexInt(length(Lo_D));
lx = coder.internal.indexInt(length(x));

% Extend, Decompose &  Extract coefficients.
first = TWO - shift;
if ~isequal(dwtEXTM,'per')
    lenEXT = lf - 1;
    last = lx + lf - 1;
else
    lenEXT = eml_rshift(lf,ONE);
    last = lx + eml_bitand(lx,ONE);
end
y = wextend('1D',dwtEXTM,x,lenEXT);

% Compute coefficients of approximation.
z = wconv1(y,Lo_D,'valid'); 
a = z(first:2:last);

% Compute coefficients of detail.
z = wconv1(y,Hi_D,'valid'); 
d = z(first:2:last);

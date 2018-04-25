function x = idwt(a,d,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(3,9)
coder.internal.prefer_const(varargin);
% Check arguments.
[Lo_R,Hi_R,dwtEXTM,shift,lx] = parseinputs(varargin{:});
NONEMPTYA = ~isempty(a);
NONEMPTYD = ~isempty(d);
if NONEMPTYA
    % Reconstructed Approximation and Detail.
    x = upsconv1(a,Lo_R,lx,dwtEXTM,shift);
    if NONEMPTYD
        x = x + upsconv1(d,Hi_R,lx,dwtEXTM,shift);
    end
elseif NONEMPTYD
    % Reconstructed Approximation and Detail.
    x = upsconv1(d,Hi_R,lx,dwtEXTM,shift);
else
    xtype = coder.internal.scalarEg(a,d);
    x = zeros(size(a),'like',xtype);
end

%--------------------------------------------------------------------------

function [Lo_R,Hi_R,dwtEXTM,shift,lx] = parseinputs(varargin)
coder.internal.prefer_const(varargin);
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersConst(varargin{1},'r');
    next = coder.internal.indexInt(2);
else
    Lo_R = varargin{1};
    Hi_R = varargin{2};
    next = coder.internal.indexInt(3);
end
% Find lx, if supplied.
ilx = coder.const(findNonChar(varargin{next:nargin}));
next = next + ilx;
if ilx == 0
    % lx not supplied.
    lx = zeros(1,0);
else
    lx = varargin{next - 1};
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
shift_input = coder.internal.indexInt(coder.internal.getParameterValue( ...
    pstruct.shift,shift_default,varargin{next:end}));
shift = eml_bitand(shift_input,coder.internal.indexInt(1));

%--------------------------------------------------------------------------

function idx = findNonChar(varargin)
% Return the index of the first non-char input, if any, otherwise 0.
idx = 0;
for k = coder.unroll(1:nargin)
    if ~ischar(varargin{k})
        idx = k;
        break
    end
end

%--------------------------------------------------------------------------

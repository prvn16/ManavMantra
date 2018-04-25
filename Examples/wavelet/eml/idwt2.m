function x = idwt2(a,h,v,d,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(5,11)
coder.internal.prefer_const(varargin);
[Lo_R,Hi_R,dwtEXTM,shift,sx] = parseinputs(varargin{:});
% The following logic tries to avoid the need for scalar expansion when
% forming x, which is nominally the sum of 4 arrays, some of which may be
% scalar 0.
NONEMPTYA = ~isempty(a);
NONEMPTYH = ~isempty(h);
NONEMPTYV = ~isempty(v);
NONEMPTYD = ~isempty(d);
if NONEMPTYA
    x = upsconv2(a,{Lo_R,Lo_R},sx,dwtEXTM,shift); % Approximation.
elseif NONEMPTYH
    x = upsconv2(h,{Hi_R,Lo_R},sx,dwtEXTM,shift); % Horizontal Detail.
elseif NONEMPTYV
    x = upsconv2(v,{Lo_R,Hi_R},sx,dwtEXTM,shift); % Vertical Detail.
elseif NONEMPTYD
    x = upsconv2(d,{Hi_R,Hi_R},sx,dwtEXTM,shift); % Diagonal Detail.
else
    xtype = coder.internal.scalarEg(a,h,v,d);
    x = zeros(size(a),'like',xtype);
end
if NONEMPTYA && NONEMPTYH
    x = x + upsconv2(h,{Hi_R,Lo_R},sx,dwtEXTM,shift); % Horizontal Detail.
end
if (NONEMPTYA || NONEMPTYH) && NONEMPTYV
    x = x + upsconv2(v,{Lo_R,Hi_R},sx,dwtEXTM,shift); % Vertical Detail.
end
if (NONEMPTYA || NONEMPTYH || NONEMPTYV) && NONEMPTYD
    x = x + upsconv2(d,{Hi_R,Hi_R},sx,dwtEXTM,shift); % Diagonal Detail.
end

%--------------------------------------------------------------------------

function [Lo_R,Hi_R,dwtEXTM,shift,sx] = parseinputs(varargin)
coder.internal.prefer_const(varargin);
ONE = coder.internal.indexInt(1);
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfiltersConst(varargin{1},'r');
    next = coder.internal.indexInt(2);
else
    Lo_R = varargin{1};
    Hi_R = varargin{2};
    next = coder.internal.indexInt(3);
end
% Find lx, if supplied.
isx = coder.const(findNonChar(varargin{next:nargin}));
if isx == 0
    sx = zeros(1,0);
else
    next = next + isx;
    sx = varargin{next - 1};
end
% Check arguments for Extension and Shift.
[dwtEXTM_default,shift_default] = defaultDWTExtModeAndShift(2);
% Extract shift and mode from the remaining inputs, if supplied.
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
shift = eml_bitand(shift_input,ONE);

%--------------------------------------------------------------------------

function idx = findNonChar(varargin)
% Return the index of the first non-char input, if any, otherwise 0.
idx = coder.internal.indexInt(0);
for k = coder.unroll(coder.internal.indexInt(1):nargin)
    if ~ischar(varargin{k})
        idx = k;
        break
    end
end

%--------------------------------------------------------------------------

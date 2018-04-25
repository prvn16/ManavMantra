function [a,h,v,d] = dwt2(x,varargin)
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
[dwtEXTM_default,shift_default] = defaultDWTExtModeAndShift(2);
parms = struct( ...
    'mode',uint32(0), ...
    'shift',uint32(0));
poptions = struct( ...
    'CaseSensitivity',true, ...
    'PartialMatching','none', ...
    'StructExpand',false, ...
    'IgnoreNulls',false);
pstruct = coder.internal.parseParameterInputs(parms,poptions,varargin{next:end});
dwtEXTM = coder.internal.getParameterValue(pstruct.mode,dwtEXTM_default,varargin{next:end});
shift = coder.internal.indexInt(coder.internal.getParameterValue( ...
    pstruct.shift,shift_default,varargin{next:end}));

% Compute sizes.
lf = coder.internal.indexInt(length(Lo_D));
sx = coder.internal.indexInt(size(x));
% Extend, Decompose &  Extract coefficients.
first = TWO - shift;
if ~isequal(dwtEXTM,'per')
    sizeEXT = lf - 1;
    last = sx + lf - 1;
else
    sizeEXT = eml_rshift(lf,ONE);
    last = sx;
    for k = ONE:numel(sx)
        if eml_bitand(last(k),ONE) == ONE
            last(k) = last(k) + 1;
        end
    end
end
if length(sx) == 2
    y = wextend('addcol',dwtEXTM,double(x),sizeEXT);
    z = conv2(y,Lo_D(:)','valid');
    a = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
    h = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
    z = conv2(y,Hi_D(:)','valid');
    v = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
    d = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
else
    y1 = wextend('addcol',dwtEXTM,double(x(:,:,1)),sizeEXT);
    z = conv2(y1,Lo_D(:)','valid');
    a1 = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
    % Allocate storage for output a and copy in the first page.
    a = coder.nullcopy(zeros([size(a1),3],'like',a1));
    a(:,:,1) = a1;
    h1 = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
    % Allocate storage for output h and copy in the first page.
    h = coder.nullcopy(zeros([size(h1),3],'like',h1));
    h(:,:,1) = h1;
    z = conv2(y1,Hi_D(:)','valid');
    v1 = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
    % Allocate storage for output v and copy in the first page.
    v = coder.nullcopy(zeros([size(v1),3],'like',v1));
    v(:,:,1) = v1;
    d1 = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
    % Allocate storage for output d and copy in the first page.
    d = coder.nullcopy(zeros([size(d1),3],'like',d1));
    d(:,:,1) = d1;
    for dim = coder.unroll(2:3)    
        y1 = wextend('addcol',dwtEXTM,double(x(:,:,dim)),sizeEXT);
        z = conv2(y1,Lo_D(:)','valid');
        a(:,:,dim) = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
        h(:,:,dim) = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
        z = conv2(y1,Hi_D(:)','valid');
        v(:,:,dim) = convdown(z,Lo_D,dwtEXTM,sizeEXT,first,last);
        d(:,:,dim) = convdown(z,Hi_D,dwtEXTM,sizeEXT,first,last);
    end
end

%--------------------------------------------------------------------------

function y = convdown(x,F,dwtEXTM,lenEXT,first,last)
coder.inline('always');
x1 = x(:,first(2):2:last(2));
y1 = wextend('addrow',dwtEXTM,x1,lenEXT);
y2 = conv2(y1',F(:)','valid')';
y = y2(first(1):2:last(1),:);

%--------------------------------------------------------------------------

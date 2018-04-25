function y = dyadup(x,varargin)
%MATLAB Code Generation Library Function

%   Limitations:
%   * If x is empty, returns x (MATLAB returns []).
%   * If the following are all true:
%       1. x is a variable-size array.
%       2. x is not a variable-length column vector (x is not :-by-1).
%       3. x is column vector at run-time.
%       4. A type argument ('c', 'r', or 'm') is not supplied.
%     then the output for y = dyadup(x,k) (where the k input is optional)
%     will match y = dyadup(x,k,'c') in code generation (MATLAB returns y =
%     dyadup(x,k,'r')). In otherwords, for an input to be treated as a
%     column vector with respect to the default value of the type input, it
%     must be a variable-length vector (shape :-by-1).
%
%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.internal.prefer_const(varargin);
narginchk(1,4);
if isempty(x)
    y = x;
    return
end
if coder.internal.isConst(iscolumn(x)) && iscolumn(x) && ...
        ~(coder.internal.isConst(isscalar(x)) && isscalar(x))
    defaultType = 'r';
else
    defaultType = 'c';
end
[odd,type,forceEven] = parseOptions(defaultType,varargin{:});
% [m,n] = size(x);
m = coder.internal.indexInt(size(x,1));
n = coder.internal.prodsize(x,'above',1);
ADDINGCOLS = type == 'c' || type == 'm';
ADDINGROWS = type == 'r' || type == 'm';
[mslope,moffset,mm] = indexSlopeAndOffset(m,ADDINGROWS,odd,forceEven);
[nslope,noffset,nn] = indexSlopeAndOffset(n,ADDINGCOLS,odd,forceEven);
y = zeros(mm,nn,'like',x);
for j = 1:n
    jj = nslope*j - noffset;
    for i = 1:m
        ii = mslope*i - moffset;
        y(ii,jj) = x(i,j);
    end
end

%--------------------------------------------------------------------------

function [odd,type,forceEven] = parseOptions(defaultType,varargin)
coder.inline('always');
coder.internal.prefer_const(defaultType,varargin);
if nargin < 2
    odd = true;
    type = defaultType;
    forceEven = false;
elseif nargin == 2
    if ischar(varargin{1})
        odd = true;
        type = parseType(varargin{1});
    else
        odd = parseEvenOdd(varargin{1});
        type = defaultType;
    end
    forceEven = false;
elseif ischar(varargin{1})
    odd = parseEvenOdd(varargin{2});
    type = parseType(varargin{1});
    forceEven = nargin == 4;
else
    odd = parseEvenOdd(varargin{1});
    if ischar(varargin{2})
        type = parseType(varargin{2});
        forceEven = false;
    else
        type = defaultType;
        forceEven = true;
    end
end

%--------------------------------------------------------------------------

function odd = parseEvenOdd(k)
coder.inline('always');
coder.internal.prefer_const(k);
if islogical(k)
    odd = k;
elseif isinteger(k)
    odd = logical(eml_bitand(k,ones('like',k)));
else
    odd = 2*floor(k/2) ~= k;
end

%--------------------------------------------------------------------------

function type = parseType(s)
coder.inline('always');
coder.internal.prefer_const(s);
coder.internal.assert(ischar(s) && ~isempty(s), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
type = char(lower(s(1)));
coder.internal.assert(type == 'c' || type == 'r' || type == 'm', ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');

%--------------------------------------------------------------------------

function [slope,offset,nn] = indexSlopeAndOffset(n,adding,odd,evenLength)
% Compute parameters slope, bias, and nn for filling the expanded array.
% These parameters are defined such that
% y(slope*(1:n) - offset) = x(1:n) and length(y) = nn.
% If adding == false, then slope = 1 (and offset = 0), otherwise slope = 2.
coder.internal.prefer_const(n,adding,odd,evenLength);
ZERO = zeros('like',n);
ONE = ones('like',n);
TWO = ONE + ONE;
if adding
    slope = TWO;
    % If ODD, then the leading and trailing entries will be zero padding.
    % If ~ODD, then the leading and trailing entries will be data.
    if odd
        offset = ZERO;
        if n > 0
            if evenLength
                nn = 2*n + 2;
            else
                nn = 2*n + 1;
            end
        else
            % Do not pad when n = 0.
            nn = ZERO;
        end
    else
        offset = ONE;
        if n > 0
            if evenLength
                nn = 2*n;
            else
                nn = 2*n - 1;
            end
        else
            % Do not pad when n = 0.
            nn = ZERO;
        end
    end
else
    slope = ONE;
    offset = ZERO;
    nn = n;
end

%--------------------------------------------------------------------------

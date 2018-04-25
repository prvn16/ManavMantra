function c = idivide(a,b,opt)
%IDIVIDE  Integer division with rounding option.
% 
%   C = IDIVIDE(A,B,OPT) is the same as A ./ B for integer classes except 
%   that fractional quotients are rounded to integers using the optional 
%   rounding mode specified by OPT.  The default rounding mode is 'fix'.  
%   A and B must be real and must have the same dimensions unless one is a 
%   scalar.  The arguments A and B must belong to the same integer class.
%   Alternatively, one of the arguments can be a scalar double, while the
%   other can be any integer type except INT64 or UINT64.  The result
%   C belongs to the integer class of the input arguments.
% 
%   C = IDIVIDE(A,B) and
%   C = IDIVIDE(A,B,'fix') are the same as A./B except that fractional 
%   quotients are rounded toward zero to the nearest integers.
% 
%   C = IDIVIDE(A,B,'round') is the same as A./B for integer classes. 
%   Fractional quotients are rounded to the nearest integers.
% 
%   C = IDIVIDE(A,B,'floor') is the same as A./B except that fractional 
%   quotients are rounded toward negative infinity to the nearest integers.
% 
%   C = IDIVIDE(A,B,'ceil') is the same as A./B except that the fractional 
%   quotients are rounded toward infinity to the nearest integers.
%
%   Examples
%      a = int32([-2 2]);
%      b = int32(3);
%      idivide(a,b) returns [0 0]
%      idivide(a,b,'floor') returns [-1 0]
%      idivide(a,b,'ceil') returns [0 1]
%      idivide(a,b,'round') returns [-1 1]
% 
%   See also LDIVIDE, RDIVIDE, MLDIVIDE, MRDIVIDE. 

%   Copyright 2005-2017 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:idivide:minrhs'));
end

idivide_check(a,b);

if nargin < 3
    c = idivide_fix(a,b);
    return;
end

if (ischar(opt) && isrow(opt)) || (isstring(opt) && isscalar(opt))
    
    x = startsWith(["fix" "floor" "ceil" "round"], opt, 'IgnoreCase',true);

    if sum(x) == 1
        if x(1)
            c = idivide_fix(a,b);
        elseif x(2)
            c = idivide_floor(a,b);
        elseif x(3)
            c = idivide_ceil(a,b);
        elseif x(4)
            c = a ./ b;
        end
        return;
    end
end
error(message('MATLAB:idivide:InvalidRoundingOption')); 


%--------------------------------------------------------------------------

function idivide_check(a,b)
% Validate input.
aint = isinteger(a);
bint = isinteger(b);
if ~(isscalar(a) || isscalar(b) || isequal(size(a),size(b)))
    error(message('MATLAB:idivide:dimagree'));
end
if ~(aint || bint)
    error(message('MATLAB:idivide:OneArgumentMustBeInteger'));
end
if ~(isreal(a) && isreal(b))
    error(message('MATLAB:idivide:complexInts'));
end
if ~(aint && bint && isa(a,class(b))) 
    if ~(aint && isa(b,'double') && isscalar(b)) && ...
        ~(bint && isa(a,'double') && isscalar(a))
    error(message('MATLAB:idivide:mixedClasses'));
    elseif isa(a,'int64') || isa(a,'uint64') || ...
             isa(b,'int64') || isa(b,'uint64')
        error(message('MATLAB:idivide:scalarDoubleWith64BitInt'));
    end
end

%--------------------------------------------------------------------------

function c = idivide_fix(a,b)
% Integer division with rounding towards zero.
if isfloat(a)
    c = cast( fix( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( fix( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
end

%--------------------------------------------------------------------------

function c = idivide_floor(a,b)
% Integer division with rounding towards negative infinity.
if isfloat(a)
    c = cast( floor( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( floor( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
    idx = (b ~= 0) & (sign(a) ~= sign(b)) & ((b .* c) ~= a);
    c(idx) = c(idx) - 1;
end

%--------------------------------------------------------------------------

function c = idivide_ceil(a,b)
% Integer division with rounding towards infinity.
if isfloat(a)
    c = cast( ceil( a ./ double(b) ) , class(b) );
elseif isfloat(b)
    c = cast( ceil( double(a) ./ b ) , class(a) );
else
    c = (a - rem(a,b)) ./ b;
    idx = (b ~= 0) & (sign(a) == sign(b)) & ((b .* c) ~= a);
    c(idx) = c(idx) + 1;
end

%--------------------------------------------------------------------------

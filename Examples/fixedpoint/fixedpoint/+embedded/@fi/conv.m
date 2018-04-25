function w = conv(varargin)
%CONV   Convolution and polynomial multiplication of FI objects.
%   C = CONV(A,B) outputs the convolution of vectors A and B, at least one
%   of which must be a FI object.
%
%   C = CONV(A, B, SHAPE) returns a subsection of the convolution, as 
%   specified by the SHAPE parameter:
%     'full'  - (default) returns the full convolution,
%     'same'  - returns the central part of the convolution
%               that is the same size as A.
%     'valid' - returns only those parts of the convolution 
%               that are computed without the zero-padded edges. 
%               LENGTH(C) is MAX(LENGTH(A)-MAX(0,LENGTH(B)-1),0).
%
%   The numerictype properties of the output FI object C are determined by the 
%   fimath object properties associated with the inputs. If either A or B has 
%   an explicitly attached fimath object, that fimath object is used to 
%   compute intermediate quantities and determine the numerictype properties 
%   of C. Otherwise, the default fimath state is used to compute 
%   intermediate quantities and determine the numerictype properties of C.
%
%   If either input is a built-in data type, it is cast into a FI
%   object using best-precision rules.
%
%   The output FI object C is always associated with the default fimath 
%   state.
%
%   Refer to the MATLAB CONV reference page for more information on the 
%   convolution algorithm.
%
%   The following example illustrates the convolution of a 22 sample 
%   sequence with a 16 tap FIR filter.
%
%   u = (pi/4)*[1 1 1 -1 -1 -1 1 -1 -1 1 -1]; 
%   x = fi(kron(u,[1 1]));
%   % x, the input has numerictype s16,15;
%   % nx, the number of elements in x is 22.
%   h = firls(15, [0 .1 .2 .5]*2, [1 1 0 0]);
%   % h, the filter taps, need not be cast into a FI object, CONV will
%   % automatically do this using best precision rules; in this case, the
%   % best precision numerictype of hfi = fi(h) is s16,16; 
%   % nh, the number of elements in h is 16.
%   y = conv(x,h);
%   % y, the output FI object has numerictype s36,31;
%   % ny, the number of elements in the output is 37 (nx + nh - 1);
%   % In computing the CONV output, the product type (x(i)*h(j)) is s32,31
%   % and the sum-of-products over 16 (= min(nx,nh)) terms has type
%   % s{32+log2(16)},31 - that is s36,31.
%   %
%   % Note: In this example it is assumed that the SumMode and ProductMode of
%   % the default fimath state are set to FullPrecision.
%
%   See also CONV

%   Copyright 2009-2017 The MathWorks, Inc.
%     

%-----------------------------------
% w = conv(u,v)
% w = conv(u,v,SHAPE)

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

args = parseinputs(varargin{:});

u0 = args.u;
v0 = args.v;
shape = args.shape;

if feature('FixedOpFloatingYields')
    if ~isfi(u0) && isfloat(u0)
        F = v0.fimath;
        if strcmp(F.FixedOpFloatingYields,'Floating')
            v0 = cast(v0,'like',u0);
            w = conv(u0,v0,shape);
            return
        end
    elseif ~isfi(v0) && isfloat(v0)
        F = u0.fimath;
        if strcmp(F.FixedOpFloatingYields,'Floating')
            u0 = cast(u0,'like',v0);
            w = conv(u0,v0,shape);
            return
        end
    end
end

[u, isuwithfm] = process_raw_input(u0,v0,varargin{1});
[v, isvwithfm] = process_raw_input(v0,u0,varargin{2});

if isuwithfm&&isvwithfm&&~isequal(fimath(u),fimath(v))
    error(message('fixed:fi:fimathMismatch'));
end
if ~isequal(u.DataType,v.DataType)
    error(message('fixed:fi:unsupportedMixedMath','conv'));
end

islocfimath = (isuwithfm||isvwithfm);
if ~islocfimath
    f = fimath;
elseif isuwithfm
    f = fimath(u);
else
    f = fimath(v);
end
    
isEmptyU = isempty(u);
isEmptyV = isempty(v);
if (isscalar(u)||isscalar(v))
    
    w = u*v;
    
elseif isfloat(u)
    
    w = embedded.fi(conv(double(u),double(v),shape),numerictype(u));
        
elseif (isEmptyU&&isEmptyV) 
    
    w = process_empty(u,v,f,~strcmpi(shape, 'full'));
    
elseif (isEmptyU||isEmptyV)
    
    w = process_empty(u,v,f,isEmptyV);

else
    
    switch shape
        case 'full'
            w = convF(u,v);
        case 'same'
            w = convS(u,v);
        case 'valid'
            w = convV(u,v);
    end

end

w.fimathislocal = false;
%-----------------------------------

function args = parseinputs(varargin)

p = inputParser;
p.addRequired('u',@validate_ip);
p.addRequired('v',@validate_ip);
p.addOptional('shape','full',@validate_shape);
p.parse(varargin{:});
args = p.Results;

%-----------------------------------

function val_ip = validate_ip(x)
val_ip = false; %#ok
if ~isvector(x) || ~(isnumeric(x))
    
    error(message('fixed:fi:inputsNotNumericVectors','conv'));
    
elseif isfi(x)&&isslopebiasscaled(numerictype(x))
    
    error(message('fixed:fi:unsupportedSlopeBias','conv'));

elseif isfi(x)&&isboolean(x)   
    
    error(message('fixed:fi:unsupportedBooleanMath'));
    
else
    
    val_ip = true;
    
end
        
%-----------------------------------

function val_shape = validate_shape(shape)

if ~ischar(shape)||(~strcmpi(shape,'full')&&~strcmpi(shape,'same')&&...
        ~strcmpi(shape,'valid'))
    
    val_shape = false; %#ok
    error(message('fixed:fi:convIncorrectShapeInput'));
    
else
    
    val_shape = true;    
    
end

%-----------------------------------

function [u, isuwithfm] = process_raw_input(u0,v0,uRef)

if ~isempty(u0)&&~isfi(u0)
    
    tU0 = emlGetBestPrecForMxArray(u0,numerictype(v0));
    u = embedded.fi(u0,tU0);
    isuwithfm = false;
    
elseif isempty(u0)&&~isfi(u0)
    
    u = embedded.fi(u0);
    isuwithfm = false;
    
else
    
    u = u0;
    isuwithfm = isfimathlocal(uRef);    
    
end
u.fimathislocal = isuwithfm;

%-----------------------------------
function w = process_empty(u,v,Fm,szIsFromU)

tW0 = emlGetNTypeForMTimes(numerictype(u),numerictype(v),Fm,isreal(u),...
                                isreal(v),1,true,Fm.MaxProductWordLength);
if szIsFromU
    
    w = embedded.fi(zeros(size(u)),tW0);
    
else
    
    w = embedded.fi(zeros(size(v)),tW0);
    
end

%-----------------------------------

% LocalWords:  nx hfi nh ny

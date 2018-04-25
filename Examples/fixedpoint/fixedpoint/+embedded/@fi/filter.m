function [y, zf] = filter(b,a,x,varargin)
%FILTER One-dimensional digital filter of FI objects.
%   Y = FILTER(B,1,X) filters the data in vector X with the filter
%   described by the vector B to create the filtered data Y.  B and X must
%   be FI objects.
%
%   The filter is a "Direct-Form Transposed" FIR implementation of the
%   difference equation:
%
%   y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%
%   FILTER always operates along the first non-singleton dimension,
%   namely dimension 1 for column vectors and non-trivial matrices,
%   and dimension 2 for row vectors.
%
%   [Y,Zf] = FILTER(B,1,X,Zi) gives access to initial and final conditions,
%   Zi and Zf, of the delays.  Zi is a vector of length LENGTH(B)-1, or an
%   array with the leading dimension of size LENGTH(B)-1 and with remaining
%   dimensions matching those of X. Zi must be a FI object with the same
%   data type as Y.
%
%   FILTER(B,1,X,[],DIM) or FILTER(B,1,X,Zi,DIM) operates along the
%   dimension DIM.
%
%   % Example: Use a basic FIR filter to remove sinusoid with frequency
%   %          w2 = 0.6*pi rad/sample.
%   w1 = .1*pi; w2 = .6*pi;
%   n  = 0:999;
%   xd = sin(w1*n) + sin(w2*n);
%   x  = sfi(xd,12);
%   b  = ufi([.1:.1:1,1-.1:-.1:.1]/4,10);
%   y  = filter(b,1,x);
%
%   See also EMBEDDED.FI/CONV, FILTER, CONV

%   Copyright 2009-2012 The MathWorks, Inc.

narginchk(3,5);

[zi,dim,fm] = parse_inputs(b,a,x,varargin{:});

L = length(b);

% Determine appropriate numeric type given the bit growth in the
% accumulation
try
    T = emlGetNTypeForMTimes(numerictype(b),numerictype(x),fm,...
        isreal(b),isreal(x),L,true,65535,'FILTER');
    if isempty(T)
        throwNumericTypeForTimesErrorMessage('');
    end
catch ME
    throwNumericTypeForTimesErrorMessage(ME);
end

% Check that the states have the correct fixed-point settings
if isfixed(T) && ~(isempty(zi) || isfi(zi) && isequal(numerictype(zi), T))
    error(message('fixed:fi:filterIncorrectStateNumerictype',...
                  get(T,'DataType'), get(T,'Signedness'),...
                  get(T,'WordLength'), get(T,'FractionLength')));
end

if isfloat(T) || isscaleddouble(T) || ...
        isfixed(T) && T.WordLength <= 53 && ...
        isequal(fm.ProductMode,'FullPrecision') && ...
        isequal(fm.SumMode,'FullPrecision')
    % Optimize full-precision case if less than 54 bits are involved
    
    switch T.DataType
        case 'single'
            [yt,zft] = filter(single(b),1,single(x),single(zi),dim);
        otherwise
            [yt,zft] = filter(double(b),1,double(x),double(zi),dim);
    end
    y = fi(yt,T);
    if isfi(zi) && isfimathlocal(zi)
        zf = fi(zft,T,fimath(zi));
    else
        zf = fi(zft,T);
    end
else
    s = size(x); % Save the original size of x
    if dim<=length(s)
        [x,perm,nshifts] = shiftdata(x,dim);
        s_shift = size(x); % New size
        x = reshape(x,s_shift(1),prod(s_shift(2:end))); % Force into 2-D
    else
        % dim exceeds ndims, so each element of x is a channel
        x = reshape(x,1,numberofelements(x));
        s_shift = size(x); % New size
    end
    
    y = fi(zeros(size(x)),T);
    
    if isfixed(T) && ...
            isequal(fm.ProductMode,'FullPrecision') && ...
            isequal(fm.SumMode,'FullPrecision') && ...
            isempty(zi) && ...
            nargout < 2 
        % Full-precision case, > 54 bits. Use conv for vectors but only if
        % final conditions are not requested and no initial conditions are
        % given
        
        s1  = struct('type','()','subs',{{':',1}});
        s2 = struct('type','()','subs',{{1:size(x,1)}});
        for k = 1:size(x,2),
            s1.subs={':',k};
            tmp = conv(b,x.subsref(s1));
            y = y.subsasgn(s1,tmp.subsref(s2));
        end
        
    else
        % General case
        % Set appropriate fimath
        try
            Tm = emlGetNTypeForTimes(numerictype(b),numerictype(x),fm,...
                isreal(b),isreal(x),65535);
        catch ME
            throwNumericTypeForTimesErrorMessage(ME);
        end
        
        fm.ProductMode = 'SpecifyPrecision';
        fm.ProductWordLength = Tm.WordLength;
        fm.ProductFractionLength = Tm.FractionLength;
        fm.SumMode='SpecifyPrecision';
        fm.SumWordLength = T.WordLength;
        fm.SumFractionLength = T.FractionLength;
        
        if isempty(zi)
            ztemp = fi(zeros(L-1,size(x,2)),T);
        else
            ztemp = zi;
        end
        if size(ztemp,2) == 1,
            ztemp = repmat(ztemp,1,size(x,2));
        end
        z = [zeros(1,size(x,2));ztemp];
        
        
        if isfi(zi) && isfimathlocal(zi)
            zf = fi(zeros(size(ztemp)),T,fimath(zi));
        else
            zf = fi(zeros(size(ztemp)),T);
        end
        
        % zf is created as a 2-D array so indexing will work in the filter algorithm.
        % It is reshaped to the correct N-D array at the end.
        size_zf = state_dimensions(length(b),s,dim);
        size_zf_2d = size(zf);
        if size_zf_2d(1) ~= L-1 || prod(size_zf(2:end)) ~= size_zf_2d(2)
            error(message('fixed:fi:filterInvalidInitialConditionSize'));
        end
        
        for k = 1:size(x,2),
            for n = 1:size(x,1),
                for m = 1:L-1,
                    %acc = b(m)*x(n,k) + z(m+1,k);
                    acc = fm.add(fm.mpy(getElement(b,m),getElement(x,n,k)),getElement(z,m+1,k));
                    %z(m) = acc;
                    setElement(z,acc,m,k);
                end
                %z(L,k) = b(L)*x(n,k);
                setElement(z,fm.mpy(getElement(b,L),getElement(x,n,k)),L,k);
                %y(n,k) = z(1,k);
                setElement(y,getElement(z,1,k),n,k);
            end
            
            for m = 1:L-1,
                setElement(zf,getElement(z,m+1,k),m,k);
            end
        end
        if ~isequal(size(zf), size_zf)
            zf = reshape(zf, size_zf);
        end
    end
    
    % Rearrange y to x's original shape
    if dim<=length(s)
        ly = size(y,1);
        s(dim) = ly;
        s_shift(1) = ly;
        y = reshape(y,s_shift); % Back to N-D array
        y = unshiftdata(y,perm,nshifts);
    end
    y = reshape(y,s);        
end

y.fimath = [];
if ~isfi(zi) || isfi(zi) && ~isfimathlocal(zi)
    zf.fimath = [];
end

%--------------------------------------------------------------------------
function [zi,dim,fm] = parse_inputs(b,a,x,varargin)

if nargin<4
    zi = [];
else
    zi = varargin{1};
end

if nargin<5
    % Default dim is the first nonsingleton dimension of x
    dim = find(size(x)~=1,1,'first');
    if isempty(dim), dim = 1; end
else
    dim = varargin{2};
end

if isfi(dim)
    % Let dimensions that happen to get cast to fi objects "just work".
    dim = double(dim);
end

if ~isnumeric(dim) || ~isscalar(dim) || ~isreal(dim) || dim<1 || ...
        dim~=floor(dim)
    error(message('fixed:fi:invalidDimInput'));
end


if ~isvector(b)
    error(message('fixed:fi:filterNumVectorOnly'));
end



% Only FIR is supported for now, check that a=1
if ~isscalar(a) || a ~= 1,
    error(message('fixed:fi:filterSupportFIROnly'));
end

try
    checkdt(b,x,zi);
catch ME
    throw(ME);
end

% Check DTO after checking data types
try
    checksamedatatypes(b,x,zi);
catch ME
    throw(ME);
end

% Determine fimath to use
try
    if isfi(zi)
        fm = fimath2use(b,x,zi);
    else
        fm = fimath2use(b,x);
    end
catch ME
    throw(ME);
end

%--------------------------------------------------------------------------
function checkdt(b,x,zi)

if ~isfi(b) || ~isfi(x) || ~isempty(zi) && ~isfi(zi)
    error(message('fixed:fi:inputArgsNotFis'));
end

%--------------------------------------------------------------------------
function checksamedatatypes(b,x,zi)

if ~isequal(get(b,'DataType'), get(x,'DataType')) || ...
        ~(isempty(zi) || isequal(get(b,'DataType'), get(zi,'DataType')))
    error(message('fixed:fi:unsupportedMixedMath','filter'));
end


%--------------------------------------------------------------------------
function size_zf = state_dimensions(length_b,size_x,dim)
% Compute the dimensions of the states, zf.
% The leading dimension of zf is numel(b)-1, and the rest of the
% dimensions are the same as size(x) with dimension dim missing.
if dim>length(size_x)
    p = prod(size_x);
else
    p = prodsize_except_dim(size_x,dim);
end
if length(size_x)==2 && size_x(2)==1
    % x is a column vector
    size_zf = [length_b-1 p];
else
    if dim<=length(size_x)
        size_zf = [length_b-1 size_x(1:dim-1) size_x(dim+1:end)];
    else
        size_zf = [length_b-1 size_x];
    end
end

%--------------------------------------------------------------------------
function n = prodsize_except_dim(size_x,dim)
%   Returns
%   n = size(x,1)*size(x,2)*...*size(x,dim-1)*size(x,dim+1)*...

if dim>length(size_x)
    n = prod(size_x);
else
    size_x(dim) = 1;
    n = numel(zeros(size_x));
end

%--------------------------------------------------------------------------------------------------
function throwNumericTypeForTimesErrorMessage(errException)
% Throw an error message from the fixed:fi message catalog based on an
% exception thrown from call to emlGetNTypeForTimes or emlGetNTypeForMTimes
if ~isempty(strfind(errException.message,'SumMode'))
    error(message('fixed:fi:filterInsufficientMaxSumWordLength'));
else % ProductMode error
    error(message('fixed:fi:filterInsufficientMaxProdWordLength'));
end

%---------------------------------------------------------------------------------------------------

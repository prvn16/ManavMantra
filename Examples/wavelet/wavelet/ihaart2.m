function xrec = ihaart2(a,h,v,d,varargin)
%IHAART2 Inverse Haar 2-D wavelet transform
% XREC = IHAART2(A,H,V,D) returns the 2-D inverse Haar transform, XREC, for
% the approximation coefficients, A, and matrices, or cell array of wavelet
% coefficients in H, V, and D. A, H, V, and D are outputs of HAART2. If A,
% H, V, and D are matrices, the 2-D Haar transform was computed only down
% to one level coarser in resolution.
% 
% XREC = IHAART2(A,H,V,D,LEVEL) returns the inverse 2-D Haar transform at
% level, LEVEL. LEVEL is a nonnegative integer less than or equal to
% length(H)-1 if H is a cell array. If H is a matrix, LEVEL must equal 0 or
% be unspecified.
%
% XREC = IHAART2(...,INTEGERFLAG) specifies how the inverse Haar 
% transform handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the 
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the inverse Haar transform still uses floating-point arithmetic
% in both cases. However, the lifting transform is implemented in a manner
% that preserves integer-valued data. The 'integer' option is only
% applicable if all elements of the inputs, A, H, V, and D, are
% integer-valued.
%
%
%   %Example 1:
%   load woman;
%   [A,H,V,D] = haart2(X);
%   xrec = ihaart2(A,H,V,D);
%   subplot(2,1,1)
%   imagesc(X); title('Original Image');
%   subplot(2,1,2)
%   imagesc(xrec); title('Inverted Haar Transform');
%
%   %Example 2:
%   im = imread('mandrill.png');
%   [A,H,V,D] = haart2(im);
%   XREC = ihaart2(A,H,V,D);
%   subplot(2,1,1)
%   imagesc(im); title('Original RGB Image');
%   axis off;
%   subplot(2,1,2)
%   imagesc(uint8(XREC)); title('Reconstructed RGB Image');
%   axis off;
%
% See also haart2, haart, ihaart

%Check number of inputs and outputs
narginchk(4,6)
nargoutchk(0,1);

%Check for integer flag
validopts = ["noninteger","integer"];
defaultopt = "noninteger";

[transformtype,varargin] = ...
    wavelet.internal.getmutexclopt(validopts,defaultopt,varargin);
if startsWith(transformtype,"int")
    integerflag = 1;
else
    integerflag = 0;
end

params = parseinputs(a,h,v,d,varargin{:});
level = params.lev;
Nlevels = params.Nlevels;
h = params.h;
v = params.v;
d = params.d;
if level>0
    for kk = 1:level
        h{kk} = zeros(size(h{kk}),'like',h{kk});
        v{kk} = zeros(size(v{kk}),'like',v{kk});
        d{kk} = zeros(size(d{kk}),'like',d{kk});
    end
end
for jj = Nlevels:-1:1
    a = ihlwt2(a,h{jj},v{jj},d{jj},integerflag);
end
xrec = a;









function x = ihlwt2(a,h,v,d,integerflag)
%IHLWT2 Haar (Integer) Wavelet reconstruction 2-D using lifting.
%   IHLWT2 performs performs the 2-D lifting Haar wavelet reconstruction.
%
%   X = IHLWT2(CA,CH,CV,CD) computes the reconstructed matrix X
%   using the approximation coefficients vector CA and detail 
%   coefficients vectors CH, CV, CD obtained by the Haar lifting  
%   wavelet decomposition.
%
%   X = IHLWT2(CA,CH,CV,CD,INTFLAG) computes the reconstructed 
%   matrix X, using the integer scheme.
%



% Test for odd input.
odd_Col = size(d,2)<size(a,2);
if odd_Col , d(:,end+1,:) = 0; v(:,end+1,:) = 0;  end
odd_Row = size(d,1)<size(a,1);
if odd_Row , d(end+1,:,:) = 0; h(end+1,:,:) = 0;  end

% Reverse Lifting.
if ~integerflag
    % Normalization.
    a = a/2;
    d = 2*d;
    v = (v-d/2);      % Reverse primal lifting.
else
    v = (v-fix(d/2)); % Reverse primal lifting.
end
d = v+d;   % Reverse dual lifting.

% Merging.
%nbR = size(d,1)+size(v,1);
%nbC = size(d,2);
SZ = size([d ; v]);
H = zeros(SZ,'like',v);
H(1:2:end,:,:) = v;
H(2:2:end,:,:) = d;

% Reverse Lifting.
if ~integerflag
    a = (a-h/2);      % Reverse primal lifting.
else
    a = (a-fix(h/2)); % Reverse primal lifting.
end
h = a+h;   % Reverse dual lifting.

% Merging.
L = zeros(SZ,'like',a);
L(1:2:end,:,:) = a;
L(2:2:end,:,:) = h;

% Reverse Lifting.
if ~integerflag
    L = (L-H/2);      % Reverse primal lifting.
else
    L = (L-fix(H/2)); % Reverse primal lifting.
end
H = L+H;   % Reverse dual lifting.

% Merging.
%nbC = size(L,2)+size(H,2);
%nbR = size(L,1);
SZX = size([L H]);
x = zeros(SZX,'like',a);
x(:,1:2:end,:) = L;
x(:,2:2:end,:) = H;

% Test for odd output.
if odd_Col , x(:,end,:) = []; end
if odd_Row , x(end,:,:) = []; end

function params = parseinputs(a,h,v,d,varargin)
params.lev = 0;
validateattributes(a,{'numeric'},{'3d','real','finite','nonempty'},...
    'ihaart2','A',1);
if (ndims(a) == 3 && size(a,3) ~= 3) || ndims(a) == 1
    error(message('Wavelet:FunctionInput:InvalidMatrixInput'));
end

[h,v,d] = validatewaveletcoeffs(h,v,d);
params.h = h;
params.v = v;
params.d = d;

if iscell(d)
params.Nlevels = length(d);
else
    params.Nlevels = 1;
end

if any(cellfun(@ischar,varargin))
    error(message('Wavelet:FunctionInput:UnrecognizedString'));
end


if isempty(varargin)
    return;
else
    tf = cellfun(@isnumeric,varargin);
end

if nnz(tf) == 1
    params.lev = varargin{tf>0};
    validateattributes(params.lev,{'numeric'},{'integer','scalar','>=',0,...
        '<',params.Nlevels},'ihaart2','LEVEL');
end

function [h,v,d] = validatewaveletcoeffs(h,v,d)

if iscell(h) && iscell(v) && iscell(d)
    
    ndimh = cellfun(@ndims,h);
    if ~all(ndimh == 2) && ~all(ndimh == 3)
         error(message('Wavelet:FunctionInput:InvalidMatrixInput'));
    end
    validationFunc = @(x)validateattributes(x,{'double'},...
        {'nonempty','real','finite'},'ihaart2','H,V,D');
    cellfun(validationFunc,h);
    cellfun(validationFunc,v);
    cellfun(validationFunc,d);
end

if ~iscell(h) && ~iscell(v) && ~iscell(d)
    szh = size(h);
    szv = size(v);
    szd = size(d);
    
    % Get dimension of H details for testing
    ndimh = ndims(h);
    if ~all(ndimh == 2) && ~all(ndimh == 3)
         error(message('Wavelet:FunctionInput:InvalidMatrixInput'));
    end
    
    validateattributes(h,{'double'},{'nonempty','real','finite'},...
        'ihaart2','H');
    validateattributes(v,{'double'},{'nonempty','real','finite'},...
        'ihaart2','V');
    validateattributes(d,{'double'},{'nonempty','real','finite'},...
        'ihaart2','D');
    
    if length(szh) == 2
        h = mat2cell(h,szh(1),szh(2));
        v = mat2cell(v,szv(1),szv(2));
        d = mat2cell(d,szd(1),szd(2));
    else
        h = mat2cell(h,szh(1),szh(2),3);
        v = mat2cell(v,szv(1),szv(2),3);
        d = mat2cell(d,szd(1),szd(2),3);
    end
end




    
        



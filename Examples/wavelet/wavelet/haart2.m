function [a,h,v,d] = haart2(x,varargin)
%HAART2 Haar 2-D wavelet transform
% [A,H,V,D] = HAART2(X) performs the 2-D Haar discrete wavelet transform
% (DWT) of the matrix, X. X is a 2-D or 3-D matrix. If X is 3-D, the third
% dimension of X must equal 3. The row and column sizes of X must be even
% length. If the row and column dimensions of X are powers of two, the Haar
% transform is obtained down to level log2(min(size(X))). If the row or
% column dimension of X is even, but not a power of two, the Haar transform
% is obtained down to level floor(log2(min(size(X)/2))). A is the
% approximation coefficients at the coarsest level. H, V, and D are cell
% arrays of matrices containing the 2-D wavelet horizontal, vertical, and
% diagonal details by level. If the Haar transform is only computed at one
% level coarser in resolution, H, V, and D are matrices.
%
% [A,H,V,D] = HAART2(X,LEVEL) performs the 2-D Haar transform down to
% level, LEVEL. LEVEL is a positive integer less than or equal to
% log2(min(size(X))) when both the row and column sizes of X are powers of
% two or floor(log2(min(size(X)/2))) when both the row and column sizes of
% X are even, but at least one is not a power of two. When LEVEL is equal
% to 1, H, V, and D are matrices.
%
% [A,H,V,D] = HAART2(...,INTEGERFLAG) specifies how the Haar 
% transform handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the 
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the Haar transform still uses floating-point arithmetic in both
% cases. However, the lifting transform is implemented in a manner that
% returns integer-valued wavelet coefficients if the input values are
% integer-valued. The 'integer' option is only applicable if all elements
% of the input, X, are integer-valued.
%
%   %Example:
%   load xbox;
%   [A,H,V,D] = haart2(xbox);
%   subplot(2,1,1)
%   imagesc(D{1})
%   title('Diagonal Level-1 Details');
%   subplot(2,1,2)
%   imagesc(H{1})
%   title('Horizontal Level 1 Details');
%
% See also ihaart2, haart, ihaart


% Check number of input and output arguments
narginchk(1,3);
nargoutchk(0,4);

% Check whether the INTEGERFLAG is used and remove
validopts = ["noninteger","integer"];
defaultopt = "noninteger";

[transformtype,varargin] = ...
    wavelet.internal.getmutexclopt(validopts,defaultopt,varargin);
if startsWith(transformtype,"int")
    integerflag = 1;
else
    integerflag = 0;
end

params = parseinputs(x,varargin{:});
if isempty(params.lev)
    lev = params.maxlev;
else
    lev = params.lev;
end

%Cast data to double-precision
x = double(x);

a = x;

for jj = 1:lev
    
    [a,h{jj},v{jj},d{jj}] = hlwt2(a,integerflag); %#ok<AGROW>
    
    
end

% If there is only one level in the MRA, returns matrices
% instead of cell arrays
if lev == 1
    h = cell2mat(h);
    v = cell2mat(v);
    d = cell2mat(d);
end



function [a,h,v,d] = hlwt2(x,integerflag)
%HLWT2 Haar (Integer) Wavelet decomposition 2-D using lifting.
%	HLWT2 performs the 2-D lifting Haar wavelet decomposition.
%
%   [CA,CH,CV,CD] = HLWT2(X) computes the approximation
%   coefficients matrix CA and detail coefficients matrices
%   CH, CV and CD obtained by the haar lifting wavelet 
%   decomposition, of the matrix X.
%
%   [CA,CH,CV,CD] = HLWT2(X,INTFLAG) returns integer coefficients.
 
% Test for odd input.
s = size(x);
odd_Col = rem(s(2),2);
if odd_Col , x(:,end+1,:) = x(:,end,:); end
odd_Row = rem(s(1),2);
if odd_Row , x(end+1,:,:) = x(end,:,:); end

% Splitting.
L = x(:,1:2:end,:);
H = x(:,2:2:end,:);

% Lifting.
H = H-L;        % Dual lifting.
if ~integerflag
    L = (L+H/2);      % Primal lifting.
else
    L = (L+fix(H/2)); % Primal lifting.
end

% Splitting.
a = L(1:2:end,:,:);
h = L(2:2:end,:,:);


% Lifting.
h = h-a;        % Dual lifting.
if ~integerflag
    
    a = (a+h/2);      % Primal lifting.
    a = 2*a;
else
    a = (a+fix(h/2)); % Primal lifting.
end

% Splitting.
v = H(1:2:end,:,:);
d = H(2:2:end,:,:);

% Lifting.
d = d-v;         % Dual lifting.
if ~integerflag
    v = (v+d/2); % Primal lifting.
    % Normalization.
    d = d/2;
else
    v = (v+fix(d/2)); % Primal lifting.
end

if odd_Col ,  v(:,end,:) = []; d(:,end,:) = []; end
if odd_Row ,  h(end,:,:) = []; d(end,:,:) = [];  end

function params = parseinputs(x,varargin)
params.lev = [];
validateattributes(x,{'numeric'},{'3d','real','finite','nonempty'},...
    'haart2','X',1);

if (ndims(x) == 3 && size(x,3) ~= 3) || ndims(x) == 1
    error(message('Wavelet:FunctionInput:InvalidMatrixInput'));
end

Ny = size(x,1);
Nx = size(x,2);
if rem(Nx,2) || rem(Ny,2)
    error(message('Wavelet:FunctionInput:InvalidRowOrColSize'));
end

N = min([Ny Nx]);
if ~rem(log2(N),1)
    params.maxlev = log2(N);
else
    params.maxlev = floor(log2(N/2));

end

if any(cellfun(@ischar,varargin))
    error(message('Wavelet:FunctionInput:UnrecognizedString'));
end

if isempty(varargin)
    return;
else
    tf = find(cellfun(@isnumeric,varargin));
end

if nnz(tf) == 1
    params.lev = varargin{tf>0};
    validateattributes(params.lev,{'numeric'},{'integer','scalar','>=',1,...
        '<=',params.maxlev},'haart2','LEVEL');
   
end





    

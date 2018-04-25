function xrec = ihaart(a,d,varargin)
%IHAART Inverse Haar 1-D wavelet transform
% XREC = IHAART(A,D) returns the 1-D inverse Haar transform, XREC, for the
% approximation coefficients, A, and vector, matrix, or cell array of
% wavelet coefficients, D. A and D are outputs of HAART. If D is a vector
% or matrix, the Haar transform was computed only down to one level coarser
% in resolution. If D is a cell array, the level of the Haar transform is
% equal to the number of elements in D. If A and the elements of D are
% vectors, XREC is a vector. If A and the elements of D are matrices, XREC
% is a matrix where each column is the inverse Haar transform of the
% corresponding columns in A and D.
%
% XREC = IHAART(A,D,LEVEL) returns the 1-D inverse Haar transform at level,
% LEVEL. LEVEL is a nonnegative integer less or equal to length(D)-1 if D
% is a cell array. If D is a vector or matrix, LEVEL must equal 0 or be
% unspecified. If unspecified, LEVEL defaults to 0.
%
% XREC = IHAART(...,INTEGERFLAG) specifies how the inverse Haar transform
% handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the 
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the inverse Haar transform still uses floating-point arithmetic
% in both cases. However, the lifting transform is implemented in a manner
% that returns integer-valued wavelet coefficients if the input values are
% integer-valued. The 'integer' option is only applicable if all elements
% of the inputs, A and D, are integer-valued.
%
%   %Example:
%   load noisdopp;
%   [a,d] = haart(noisdopp);
%   xrec = ihaart(a,d);
%   max(abs(xrec-noisdopp'))
%
%   %Example
%   x = randi(10,100,1);
%   [a,d] = haart(x,'integer');
%   xrec = ihaart(a,d,'integer');
%   subplot(2,1,1)
%   stem(x); title('Original Data');
%   subplot(2,1,2);
%   stem(xrec); title('Reconstructed Integer-to-Integer Data');
%   max(abs(x(:)-xrec(:)))
%
% See also HAART, HAART2, IHAART2

% Check number of input arguments
narginchk(2,4);
% Check number of output arguments
nargoutchk(0,1);

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

params = parseinputs(a,d,varargin{:});
level = params.lev;
Nlevels = params.Nlevels;
if Nlevels == 1
    d = mat2cell(d,size(d,1),size(d,2));
end

if level>0
    for kk = 1:level
        d{kk} = zeros(size(d{kk}),'like',d{kk});
    end
end
for jj = Nlevels:-1:1
    a = ihlwt(a,d{jj},integerflag);
end

xrec = a;
    


function x = ihlwt(a,d,integerflag)
%IHLWT Haar (Integer) Wavelet reconstruction 1-D using lifting.
%   IHLWT performs performs the 1-D lifting Haar wavelet reconstruction.
%
%   X = IHLWT(CA,CD) computes the reconstructed vector X
%   using the approximation coefficients vector CA and detail
%   coefficients vector CD obtained by the Haar lifting wavelet 
%   decomposition.
%
%   X = IHLWT(CA,CD,INTFLAG) computes the reconstructed 
%   vector X, using the integer scheme.
%


x = zeros(2*size(a,1),size(a,2),'like',a);
% Test for integer transform.

% Test for odd input.
odd = length(d(:,1))<length(a(:,1));
if odd 
    d(end+1,:) = 0; 
end

% Reverse Lifting.
if ~integerflag
    d = sqrt(2)*d;          % Normalization.
    a = a/sqrt(2);
    a = a-d/2;      % Reverse primal lifting.
else
    a = (a-fix(d/2)); % Reverse primal lifting.
end
d = a+d;   % Reverse dual lifting.

% Merging.

x(1:2:end,:) = a;
x(2:2:end,:) = d;

% Test for odd output.
if odd 
    x(end,:) = []; 
end

function params = parseinputs(a,d,varargin)
params.lev = 0;

validateattributes(a,{'numeric'},{'nonempty','finite','real'},...
    'ihaart','A',1);
validateattributes(d,{'numeric','cell'},{'nonempty'});
if isnumeric(d)
    validateattributes(d,{'numeric'},{'real','finite'},...
        'ihaart','D',2);
elseif iscell(d)
    cellfun(@(x)validateattributes(x,{'numeric'},{'finite','real'},...
        'ihaart','D',2),d);
end

if isnumeric(d)
    params.Nlevels = 1;
else
    params.Nlevels = length(d);
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
    validateattributes(params.lev,{'numeric'},...
        {'integer','scalar','>=',0,'<',params.Nlevels},...
        'ihaart','LEVEL',3);
elseif nnz(tf) > 1
    error(message('Wavelet:FunctionInput:InvalidVector'));

end






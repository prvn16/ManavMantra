function [a,d] = haart(x,varargin)
%HAART Haar 1-D wavelet transform
% [A,D] = HAART(X) performs the 1-D Haar discrete wavelet transform of the
% even-length vector, X. If X is a matrix, HAART operates on each column of
% X. If the length of X is a power of two, the Haar transform is obtained
% down to level log2(length(X)). If the length of X is even, but not a
% power of two, the Haar transform is obtained down to level
% floor(log2(length(X)/2)). A is a vector or matrix of approximation
% coefficients at the coarsest level. D is a cell array of vectors or
% matrices of wavelet coefficients. The elements of D are ordered from the
% finest resolution level to the coarsest.
%
% [A,D] = HAART(X,LEVEL) obtains the Haar transform down to level,
% LEVEL. LEVEL is a positive integer less than or equal to log2(length(X))
% when the length of X is a power of two or floor(log2(length(X)/2)) when
% the length of X is even, but not a power of two. If LEVEL is equal to 1,
% D is returned as a vector, or matrix.
%
% [A,D] = HAART(...,INTEGERFLAG) specifies how the Haar transform
% handles integer-valued data.
% 'noninteger'  -   (default) does not preserve integer-valued data in the
%                   Haar transform.
% 'integer'     -   preserves integer-valued data in the Haar transform.
% Note that the Haar transform still uses floating-point arithmetic in both
% cases. However, the lifting transform is implemented in a manner that
% returns integer-valued wavelet coefficients if the input values are
% integer-valued. The data type of A and D is always double. The 'integer'
% option is only applicable if all elements of the input, X, are
% integer-valued.
%
%   % Example 1: Obtain the Haar transform down to the maximum level.
%   load wecg;
%   [A,D] = haart(wecg);
%
%   %Example 2: Obtain the Haar transform of a multivariate time series
%   %   dataset of electricity consumption data.
%   load elec35_nor;
%   signals = signals';
%   [a,d] = haart(signals);
%
% See also ihaart, haart2, ihaart2

% Check number of inputs
narginchk(1,3);
% Check number of outputs
nargoutchk(0,2);
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
if isvector(x)
    x = x(:);
end

% Cast x to double
x = double(x);


a = x;
for jj = 1:lev
    
    [a,d{jj}] = hlwt(a,integerflag); %#ok<AGROW>
end

if lev == 1
    d = cell2mat(d);
end





function [a,d] = hlwt(x,integerflag)
% Haar lifting analysis step
%

% Test for integer transform.
notInteger = ~integerflag;

% Test for odd input.
odd = rem(length(x(:,1)),2);
if odd
    x(end+1,:) = x(end,:);
end

% Lazy wavelet step
a = x(1:2:end,:);
d = x(2:2:end,:);

% Dual lifting step
d = d-a;

if notInteger
    % Primal lifting -- update scaling coefficients
    a = a+d/2;
    % Normalization step of wavelet transform
    d = d/sqrt(2);
    a = sqrt(2)*a;
else
    a = a+fix(d/2); % Primal lifting.
end

% Test for odd output.
if odd
    d(end,:) = [];
end

function params = parseinputs(x,varargin)
params.lev = [];
if isrow(x)
    x = x.';
end
validateattributes(x,{'numeric'},{'finite','nonempty','real'},...
    'haart','X',1);
sz = size(x);
if length(sz)> 2
    error(message('Wavelet:FunctionInput:InvalidSizeHaart'));
end

N = sz(1);
if rem(N,2)
    error(message('Wavelet:FunctionInput:EvenLength'));
end

% Check if N is a power of two
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
    tflevel = find(cellfun(@isscalar,varargin));
    
end

if nnz(tflevel) == 1
    params.lev = varargin{tflevel>0};
    validateattributes(params.lev,{'numeric'},...
        {'integer','scalar','positive','<=',params.maxlev},'haart','LEVEL');
end



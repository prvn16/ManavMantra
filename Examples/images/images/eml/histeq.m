function [out,T] = histeq(varargin) %#codegen
%HISTEQ Enhance contrast using histogram equalization.

%   Copyright 2014-2016 The MathWorks, Inc.

%#ok<*EMCA>

narginchk(1,3);

% Output display is not supported
coder.internal.errorIf(nargout == 0, ...
    'images:histeq:codegenNoDisplay');

% Indexed image syntaxes are not supported
% HISTEQ(X,MAP,HGRAM)
coder.internal.errorIf(nargin>2,...
    'images:validate:codegenIndexedImagesNotSupported',mfilename);

NPTS = 256;
ain = varargin{1};

if nargin == 1
    %HISTEQ(I)
    validateattributes(ain,{'uint8','uint16','double','int16','single'}, ...
        {'nonsparse'}, mfilename,'I',1);
    n = 64; % Default n
    hgram = ones(n,1)*(numel(ain)/n);
else % nargin == 2
    cm = varargin{2};
    
    % HISTEQ(X,map)
    coder.internal.errorIf(size(cm,2) == 3 && size(cm,1) > 1,...
        'images:validate:codegenIndexedImagesNotSupported',mfilename);
    
    % HISTEQ(I,N)
    validateattributes(ain,{'uint8','uint16','double','int16','single'}, ...
        {'nonsparse'}, mfilename,'I',1);
    
    % Use isscalar for a run-time switch
    if isscalar(cm)
        %HISTEQ(I,N)
        validateattributes(cm, {'single','double'},...
            {'nonsparse','integer','real','positive','scalar'},...
            mfilename,'N',2);
        
        % Empty input image
        if isempty(ain)
            out = ain;
            if cm(1) == 1
                % N = 1
                T = coder.internal.nan('double');
            else
                T = zeros(1,NPTS);
            end
            return
        end
            
        hgram = ones(cm(1),1)*(numel(ain)/cm(1));
    else
        %HISTEQ(I,HGRAM)
        validateattributes(cm, {'single','double'},...
            {'real','nonsparse','vector','nonempty'},...
            mfilename,'HGRAM',2);
        
        % Convert row to column vector
        hgram = cm(:);
        
    end
end

coder.internal.errorIf(min(size(hgram),[],2) > 1,...
    'images:histeq:hgramMustBeAVector');

% Normalize hgram
hgram = hgram*(numel(ain)/sum(hgram(:)));
m = length(hgram);

if isa(ain,'int16')
    classChanged = true;
    a = im2uint16(ain);
else
    classChanged = false;
    a = ain;
end

[nn,cum] = computeCumulativeHistogram(a,NPTS);
T = createTransformationToIntensityImage(a,hgram,m,NPTS,nn,cum);

b = grayxform(a, T);

if classChanged
    out = im2int16(b);
else
    out = b;
end

%--------------------------------------------------------------
function [nn,cum] = computeCumulativeHistogram(img,nbins)

coder.inline('always');
nn = imhist(img,nbins)';
cum = cumsum(nn);

%--------------------------------------------------------------
function T = createTransformationToIntensityImage(a,hgram,m,n,nn,cum)

coder.inline('always');
cumd = cumsum(hgram*numel(a)/sum(hgram(:)));

% Create transformation to an intensity image by minimizing the error
% between desired and actual cumulative histogram.
tol = ones(m,1)*min([nn(1:n-1),0;0,nn(2:n)],[],1)/2;
err = (cumd(:)*ones(1,n)-ones(m,1)*cum(:)')+tol;

for i = 1:numel(err)
    if err(i) < -numel(a)*sqrt(eps)
        err(i) = numel(a);
    end
end

[~,T] = min(err,[],1);

if m == 1
    % Set T to Inf
    T = coder.internal.inf(size(T),'like',T);
else
    T = (T-1)/(m-1);
end

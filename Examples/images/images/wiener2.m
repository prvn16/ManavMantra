function [f,noise] = wiener2(varargin)
%WIENER2 2-D adaptive noise-removal filtering.
%   WIENER2 lowpass filters an intensity image that has been degraded by
%   constant power additive noise. WIENER2 uses a pixel-wise adaptive Wiener
%   method based on statistics estimated from a local neighborhood of each
%   pixel.
%
%   J = WIENER2(I,[M N],NOISE) filters the image I using pixel-wise adaptive
%   Wiener filtering, using neighborhoods of size M-by-N to estimate the local
%   image mean and standard deviation. If you omit the [M N] argument, M and N
%   default to 3. The additive noise (Gaussian white noise) power is assumed
%   to be NOISE.
%
%   [J,NOISE] = WIENER2(I,[M N]) also estimates the additive noise power
%   before doing the filtering. WIENER2 returns this estimate as NOISE.
%
%   Class Support
%   -------------
%   The input image I can be uint8, uint16, int16, double, or single.  The
%   output image J has the same class as I.
%
%   Example
%   -------
%       RGB = imread('saturn.png');
%       I = rgb2gray(RGB);
%       J = imnoise(I,'gaussian',0,0.005);
%       K = wiener2(J,[5 5]);
%       figure, imshow(J), figure, imshow(K)
%
%   See also FILTER2, MEDFILT2.

%   Copyright 1993-2013 The MathWorks, Inc.


% Reference: "Two-Dimensional Signal and Image Processing" by 
% Jae S. Lim, p. 538, equations 9.26, 9.27, and 9.29.

[g, nhood, noise] = ParseInputs(varargin{:});

classin = class(g);
classChanged = false;
if ~isa(g, 'double')
  classChanged = true;
  g = im2double(g);
end

% Estimate the local mean of f.
localMean = filter2(ones(nhood), g) / prod(nhood);

% Estimate of the local variance of f.
localVar = filter2(ones(nhood), g.^2) / prod(nhood) - localMean.^2;

% Estimate the noise power if necessary.
if (isempty(noise))
  noise = mean2(localVar);
end

% Compute result
% f = localMean + (max(0, localVar - noise) ./ ...
%           max(localVar, noise)) .* (g - localMean);
%
% Computation is split up to minimize use of memory
% for temp arrays.
f = g - localMean;
g = localVar - noise; 
g = max(g, 0);
localVar = max(localVar, noise);
f = f ./ localVar;
f = f .* g;
f = f + localMean;

if classChanged
  f = images.internal.changeClass(classin, f);
end


%%%
%%% Subfunction ParseInputs
%%%
function [g, nhood, noise] = ParseInputs(varargin)

nhood = [3 3];
noise = [];

switch nargin
case 0
    error(message('images:wiener2:tooFewInputs'));
    
case 1
    % wiener2(I)
    
    g = varargin{1};
    
case 2
    g = varargin{1};

    switch numel(varargin{2})
    case 1
        % wiener2(I,noise)
        
        noise = varargin{2};
        
    case 2
        % wiener2(I,[m n])

        nhood = varargin{2};
        
    otherwise
        error(message('images:validate:invalidSyntax'))
    end
    
case 3
    g = varargin{1};
        
    if (numel(varargin{3}) == 2)
        % wiener2(I,[m n],[mblock nblock]) REMOVED
        error(message('images:removed:syntax','WIENER2(I,[m n],[mblock nblock])','WIENER2(I,[m n])'))
    else
        % wiener2(I,[m n],noise)
        nhood = varargin{2};
        noise = varargin{3};
    end
    
case 4
    % wiener2(I,[m n],[mblock nblock],noise) REMOVED
    error(message('images:removed:syntax','WIENER2(I,[m n],[mblock nblock],noise)','WIENER2(I,[m n],noise)'))

    g = varargin{1};
    nhood = varargin{2};
    noise = varargin{4};
    
otherwise
    error(message('images:wiener2:tooManyInputs'));

end

% checking if input image is a truecolor image-not supported by WIENER2
if (ndims(g) == 3)
    error(message('images:wiener2:wiener2DoesNotSupport3D')); 
end

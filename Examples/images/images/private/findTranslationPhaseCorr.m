function [vec,peakVal] = findTranslationPhaseCorr(varargin) %#codegen
%findTranslationPhaseCorr Determine translation using phase correlation.
%
%   [vec,peakVal] = findTranslationPhaseCorr(MOVING, FIXED) estimates the
%   translation of MOVING necessary to align MOVING with the
%   fixed image FIXED. The output VEC is a two element vector of the form
%   [deltaX, deltaY]. The scalar peakVal is the peak value of the phase
%   correlation matrix used to estimate translation.
%
%   [vec,peakVal] = findTranslationPhaseCorr(D) estimates the translation
%   of MOVING necesary to align MOVING with the fixed image FIXED. D is a
%   phase correlation matrix of the form returned by:
%
%       D = phasecorr(fixed,moving).

%   Copyright 2013 The MathWorks, Inc.

narginchk(1,2)

if nargin == 1
    d = varargin{1};
else
    moving = varargin{1};
    fixed  = varargin{2};
    % Compute phase correlation matrix, D
    d = phasecorr(fixed,moving);
end

% Use simple global maximum peak finding. Surface fit using 3x3
% neighborhood to refine xpeak,ypeak location to sub-pixel accuracy.
subpixel = true;
[xpeak,ypeak,peakVal] = findpeak(d,subpixel);

% findpeak returns 1 based MATLAB indices. We want 0 based offset for
% translation vector.
xpeak = xpeak-1;
ypeak = ypeak-1;

outSize = size(d);

% Covert peak locations in phase correlation matrix to translation vector
% that defines translation necessary to align moving with fixed.
%
% The translation offsets implied by the phase correlation matrix have the form:
%
% [0, 1, 2,...-2, -1];
%
% The logic below figures out whether we are past the center region of the
% phase correlation matrix in which the offset signs switch from positive to
% negative, i.e. are we closer to the right edge or the left edge?
if xpeak > abs(xpeak-outSize(2))
    xpeak = xpeak-outSize(2);
end

if ypeak > abs(ypeak-outSize(1))
    ypeak = ypeak-outSize(1);
end

% Ensure that we consistently return double for the offset vector and for
% the peak correlation value.
vec = double([xpeak, ypeak]);
peakVal = double(peakVal);

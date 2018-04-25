function varargout = imhistmatchn(varargin)
%IMHISTMATCHN Adjust N-D image to match its histogram to that of reference image.
%
%   B = IMHISTMATCHN(A,REF) transforms the N-D grayscale image A so that
%   the histogram of the output image B approximately matches the histogram
%   of the reference image REF. Both A and REF must be grayscale images,
%   but they do not need to have the same size nor number of dimensions.
%
%   B = IMHISTMATCHN(A,REF,NBINS) uses NBINS equally spaced histogram bins
%   for transforming input image A. The image returned in B has no more
%   than NBINS discrete levels. The default value for NBINS is 64.
%
%   [B,HGRAM] = IMHISTMATCHN(__) returns the histogram of the reference 
%   image REF used for matching in HGRAM. HGRAM is a 1-by-NBINS matrix, 
%   where NBINS is the number of histogram bins.
% 
%   Note 
%   ----- 
%   The histograms for A and REF are computed with equally spaced bins 
%   and with intensity values in the appropriate range for each image:
%   [0,1] for images of class double or single, [0,255] for images of
%   class uint8, [0,65535] for images of class uint16, and [-32768,
%   32767] for images of class int16.
%
%   Class Support
%   -------------
%   A can be uint8, uint16, int16, double or single. The output image B has 
%   the same class as A. The optional output HGRAM is always of class double.
%
%   Example
%   -------
%   Match the histogram of a multidimensional image
%   to that of another multidimensional image
%
%      load mristack
%      load mri D
%
%      % Display the original volume as slices
%      figure
%      montage(D,'DisplayRange',[])
%      title('Original 3-D Image')
%      
%      % Reshape reference as a stack of grayscale slices
%      ref = reshape(mristack,[256,256,1,21]);
%      % Display the reference volume as slices
%      figure
%      montage(ref,'DisplayRange',[])
%      title('Reference 3-D Image')
%      
%      % Do histogram matching
%      Dmatched = imhistmatchn(D,ref);
%      
%      % Display the output
%      figure
%      montage(Dmatched,'DisplayRange',[])
%      title('Histogram Matched MRI')
%
%   See also HISTEQ, IMADJUST, IMHIST, IMHISTMATCH.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);
nargoutchk(0,2);

[A, ref, numBins] = parse_inputs(varargin{:});
% If input A is empty, then the output image B will also be empty

% Compute histogram of the reference image
% Tranpose to be conistent with imhistmatch
hgram = imhist(ref,numBins)';

% Adjust A using reference histogram
B = histeq(A,hgram);

% Always set varargout{1} so 'ans' always gets
% populated even if user doesn't ask for output
varargout{1} = B;
if (nargout == 2)
    varargout{2} = hgram;
end

%--------------------------------------------------------------------------
function [A, ref, numBins] = parse_inputs(varargin)

A = varargin{1};
validateattributes(A,{'uint8','uint16','double','int16', ...
    'single'},{'nonsparse','real'}, mfilename,'A',1);

ref = varargin{2};
validateattributes(ref,{'uint8','uint16','double','int16', ...
    'single'},{'nonsparse','real','nonempty'}, mfilename,'ref',2);

if (nargin == 3)
    numBins = varargin{3};
    validateattributes(numBins, ...
        {'numeric'}, ...
        {'scalar','nonsparse','integer','>', 1}, ...
        mfilename,'nbins',3);
else
    numBins = 64;
end

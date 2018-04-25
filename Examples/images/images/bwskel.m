function skel = bwskel(varargin)
% BWSKEL Reduce all objects to a curve skeleton in a 2-D binary image or 
% 3-D binary volume.
%
%  B = bwskel(A) computes the skeleton of a 2-D binary image. This preserves
%  the topology and euler number of the objects.
%
%  B = bwskel(V) computes the skeleton of a 3-D binary volume. This preserves
%  the topology and euler characteristics of the objects. The skeleton will always
%  be one pixel wide curve for both 2-D and 3-D inputs.
%
%  B = bwskel(__, 'MinBranchLength', N) specifies the minimum
%  branch length N of the skeleton. All branches below the length N, are 
%  pruned/removed. The length is calculated as the number of pixels in a branch
%  using 8-connectivity for 2-D and 26-connectivity for 3-D.
%  Default value of 'MinBranchLength' is 0. This equates to no pruning.
%
%  The skeleton is calculated by reducing the foreground objects, which
%  correspond to white regions in the image(logical true).
%
%   Class Support 
%   ------------- 
%   The input A must be a 2-D logical array. The input volume V must be a
%   3-D logical array. Both A and V and must be non-sparse. Output image 
%   B is a logical array of the same size as V or A.
%
%   References
%   ----------
%   [1] Ta-Chih Lee, Rangasami L. Kashyap and Chong-Nam Chu 
%   "Building skeleton models via 3-D medial surface/axis thinning algorithms." 
%   Computer Vision, Graphics, and Image Processing, 56(6):462-478, 1994.
%   [2] Kerschnitzki, Kollmannsberger et al.,
%   "Architecture of the osteocyte network correlates with bone material quality."
%   Journal of Bone and Mineral Research, 28(8):1837-1845, 2013. 
% 
%   Example: Extract the centerline
%   --------------------------------
%
%   load('spiralVol.mat');
%   volumeViewer(spiralVol);
%   
%   % Threshold the volume to get a logical volume of the spiral
%   spiralBW = imbinarize(spiralVol);
% 
%   % Compute the 3-D skeleton
%   out = bwskel(spiralBW);
% 
%   volumeViewer(out);
%
%   See also BWMORPH, BWMORPH3.

%   Copyright 2017 The MathWorks, Inc.

options = parse_inputs(varargin{:});

im = options.input;
minLen = options.MinBranchLength;

im = padarray(im,[1 1 1], 0);

skel = skel3Dmex(im);

if(minLen > 0)
   skel = images.internal.pruneEdges3(skel, minLen); 
end

% unpad
skel = skel(2:end-1, 2:end-1, 2:end-1);




function options = parse_inputs(varargin)

parser = inputParser();
parser.addRequired('input', @validateImage);
parser.addParameter('MinBranchLength', 0, @validateMinLen);

parser.parse(varargin{:});
options = parser.Results;




function tf = validateImage(im)

validateattributes(im,{'logical'},{'nonsparse','real','3d', ...
        'nonempty','nonnegative'}, mfilename,'image',1);
    tf = true;

function tf = validateMinLen(minLen)

validateattributes(minLen,{'numeric'},{'scalar','real', 'integer'...
        'nonempty','nonnegative'}, mfilename,'MinBranchLength',1);
    tf = true;









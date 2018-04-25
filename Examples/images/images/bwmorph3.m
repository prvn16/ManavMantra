function bwout = bwmorph3(V,operation)
%BWMORPH3 Morphological operations on binary volume.
%   J = BWMORPH3(V,OPERATION) applies a specific
%   morphological operation to the binary volume V.
%
%   OPERATION is a string or char vector that can have one of these values:
%      'branchpoints' Find branch points of skeleton
%      'clean'        Remove isolated voxels (1's surrounded by 0's)
%      'endpoints'    Find end points of skeleton
%      'fill'         Fill isolated interior voxels (0's surrounded by
%                     1's)
%      'majority'     Set a voxel to 1 if fourteen or more voxels in its
%                     3-by-3-by-3 neighborhood are 1's
%      'remove'       Set a voxel to 0 if its 6-connected neighbors
%                     are all 1's, thus leaving only boundary
%                     voxels
%
%   Class Support
%   -------------
%   The input volume V can be numeric or logical.
%   It must be real and nonsparse and be of the dimension 1D,2D or 3D.
%   The output volume J is logical.
%
%   Remarks
%   -------
%   To perform erosion or dilation using the structuring element ones(3,3,3),
%   use IMERODE or IMDILATE. Similarly the operations IMCLOSE, IMOPEN,
%   IMBOTHAT and IMTOPHAT can be used on 3D volumes with the said structuring element.
%
%   When feeding 1D or 2D inputs, the outputs use the 3D definition as explained above. If 
%   2D behavior is intended, make use of the function 'bwmorph' instead.
% 
%   Examples
%   --------
%   This example carries out the 'remove' and 'clean' morphological operations
%   on a 3D binary volume.
%
%   load mristack;
%   BW1 = mristack > 127;
%
%   BW2 = bwmorph3(BW1,'remove');
%   BW3 = bwmorph3(BW1,'clean');
%       
%   % Display the volumes 
%   volumeViewer(BW2)
%   volumeViewer(BW3)
%
%   See also IMERODE, IMDILATE, IMBOTHAT, IMTOPHAT, IMCLOSE, IMOPEN,
%   BWMORPH, BWSKEL.

%   Copyright 2017 The MathWorks, Inc.
[bwin,op] = parseInputs(V,operation);

s = settings; 
if ndims(bwin) == 3 && s.images.UseHalide.ActiveValue
    out = bwmorph3_halide(bwin, ['h' op]);
else
    % add padding for boundary voxels (Take care of edge and degenerate cases)
    bwPadd = padarray(bwin,[1 1 1],0);
    originalSize = size(bwPadd)-2;
    out = bwmorph3Algorithm(bwPadd,op,originalSize);
end

bwout = out;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bwin,op] = parseInputs(varargin)

narginchk(2,2);

p = inputParser;
p.addRequired('bwin',@validateVolume);
p.addRequired('op',@validateOperation);

p.parse(varargin{:});
res = p.Results;

bwin = res.bwin;
if ~islogical(bwin)
    bwin = (bwin ~= 0);
end

op = res.op;
ischar(matlab.images.internal.stringToChar(op));
% BWMORPH3(A, 'op')
%
% Find out what operation has been requested
%
validOperations = {'branchpoints',...
    'clean',...
    'endpoints',...
    'fill',...
    'majority',...
    'remove'};

op = validatestring(op,validOperations, 'bwmorph3');


function flag = validateVolume(bwin)

validateattributes(bwin,{'numeric','logical'},{'3d','nonsparse','real'},...
                   mfilename,'bwin',1);
flag = true;


function flag = validateOperation(op)

validateattributes(op,{'char','string'},{'scalartext'},...
                   mfilename,'op',2);
flag = true;
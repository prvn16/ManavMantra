function out = applyDisplacementField(in_,D_,method,fillVal,SmoothEdges)%#codegen
%applyDisplacementField Apply a displacement field to an image.
%
% B = applyDisplacementField(A,D,METHOD,FILLVAL,SmoothEdges) applies a
% displacement field D to the input image A using an interpolation method
% specified by METHOD and a fill value for pixels that map to out of bounds
% locations in A specified by FILLVAL. SmoothEdges is a logical value
% controlling the edge smoothing behavior.

% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.

% Copyright 2014-2018 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(in_,D_,method,fillVal,SmoothEdges);

inputClass = class(in_);

% Perform point mapping computation in single unless D was specified as double.
if ~isa(D_,'double')
    D = single(D_);
    in = single(in_);
else
    D = D_;
    in = double(in_);
end

% GPU code generation needs specific implementation, since with the portable
% code, the generated GPU mex fails to execute. This is due to the
% excessive stack usage when the portable code is used to generate the GPU 
% code. This excessive stack memory usage results in an 'out of memory error'.
if(coder.gpu.internal.isGpuEnabled)
    % For GPU targets
    sizeD = size(D);
    
    % Size of the query point matrices
    qSize = [sizeD(1) sizeD(2)];
    
    % Initializing the query point matrices
    xGrid = zeros(qSize);
    yGrid = zeros(qSize);
    
    % Generating querypoint matrices using the displacment vector. The
    % displacement vector contains offset values which are to be added to the output
    % grid. Thus, the output grid is mapped to source image coordinate system.
    % This piece of code is expected to generate a kernel.
    for colIdx = 1:sizeD(2)
        for rowIdx = 1:sizeD(1)
            xGrid(rowIdx,colIdx) = colIdx + D(rowIdx,colIdx,1);
            yGrid(rowIdx,colIdx) = rowIdx + D(rowIdx,colIdx,2);
        end
    end
else
    % For Non-PC targets (other than MATLAB and GPU)
    xGrid = 1:size(D,2);
    yGrid = 1:size(D,1);
    [xGrid,yGrid] = meshgrid(xGrid,yGrid);
    
    % Now map output grid into source image coordinate system using additive
    % offsets in D.
    xGrid = xGrid + D(:,:,1);
    yGrid = yGrid + D(:,:,2);
end

out = images.internal.coder.interp2d(in,xGrid,yGrid,method,fillVal,SmoothEdges);

out = cast(out,inputClass);

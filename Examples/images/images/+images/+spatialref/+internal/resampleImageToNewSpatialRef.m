function [B,RB] = resampleImageToNewSpatialRef(A,RA,RB,interpMethod,fillValue)
%resampleImageToNewSpatialRef Resample spatially referenced image to new grid.
%
%   [B,RB,MASK] = resampleImageToNewSpatialRef(A,RA,RB,FILLVALUE,METHOD)
%   resamples the spatially referenced image A,RA to a new grid whose world
%   extent and resolution is defined by RB. During resampling, the output
%   image B is assigned the value fillValue. METHOD defines the
%   interpolation method used during resampling, valid values are
%   'nearest','bilinear', and 'bicubic'. The output B,RB is an output
%   spatially referenced image. MASK is a logical image which is false
%   where fillValues were assigned and true where values of A were used to
%   define B.

% Copyright 2012 The MathWorks, Inc.

[bIntrinsicX,bIntrinsicY] = meshgrid(1:RB.ImageSize(2),1:RB.ImageSize(1));

[xWorldOverlayLoc,yWorldOverlayLoc] = RB.intrinsicToWorld(bIntrinsicX,bIntrinsicY);

% Convert these locations to intrinsic coordinates to be used in
% interpolation in image A.
[xIntrinsicLoc,yIntrinsicLoc] = RA.worldToIntrinsic(xWorldOverlayLoc,yWorldOverlayLoc);

% Resample to form output image
if isa(A,'double')
    B = images.internal.interp2d(A,xIntrinsicLoc,yIntrinsicLoc,interpMethod,fillValue);
else
    B = images.internal.interp2d(single(A),single(xIntrinsicLoc),single(yIntrinsicLoc),...
            interpMethod,fillValue);
end

% Move B back to original type
B = cast(B,class(A));


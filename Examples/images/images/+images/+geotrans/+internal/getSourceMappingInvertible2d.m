function [srcXIntrinsic,srcYIntrinsic] = getSourceMappingInvertible2d(Rin,tform,Rout)

%   Copyright 2017 The MathWorks, Inc.

%#codegen

% Form plaid grid of intrinsic points in output image.
[dstXIntrinsic,dstYIntrinsic] = meshgrid(1:Rout.ImageSize(2),1:Rout.ImageSize(1));

% Define affine transformation that maps from intrinsic system of
% output image to world system of output image.
Sx = Rout.PixelExtentInWorldX;
Sy = Rout.PixelExtentInWorldY;
Tx = Rout.XWorldLimits(1)-Rout.PixelExtentInWorldX*(Rout.XIntrinsicLimits(1));
Ty = Rout.YWorldLimits(1)-Rout.PixelExtentInWorldY*(Rout.YIntrinsicLimits(1));
tIntrinsictoWorldOutput = [Sx 0 0; 0 Sy 0; Tx Ty 1];

% Define affine transformation that maps from world system of
% input image to intrinsic system of input image.
Sx = 1/Rin.PixelExtentInWorldX;
Sy = 1/Rin.PixelExtentInWorldY;
Tx = (Rin.XIntrinsicLimits(1))-1/Rin.PixelExtentInWorldX*Rin.XWorldLimits(1);
Ty = (Rin.YIntrinsicLimits(1))-1/Rin.PixelExtentInWorldY*Rin.YWorldLimits(1);
tWorldToIntrinsicInput = [Sx 0 0; 0 Sy 0; Tx Ty 1];

% Form transformation to go from output intrinsic to input intrinsic
tComp = tIntrinsictoWorldOutput / tform.T * tWorldToIntrinsicInput;

% Find the transform that takes from input intrinsic to output intrinsic
if(isa(tform,'affine2d'))
    tformComposite = invert(affine2d(tComp(1:3,1:2)));
else
    assert(isa(tform,'projective2d'));
    tformComposite = invert(projective2d(tComp));
end

[srcXIntrinsic,srcYIntrinsic] = ...
    tformComposite.transformPointsInverse(dstXIntrinsic,dstYIntrinsic);

end
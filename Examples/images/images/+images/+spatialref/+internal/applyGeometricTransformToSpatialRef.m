function R_out = applyGeometricTransformToSpatialRef(R_in,tform)%#codegen
%   FOR INTERNAL USE ONLY -- This function is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%   Rout = resampleImageToNewSpatialRef(R_in,tform) takes a spatial
%   referencing object Rin and a geometric transformation tform. The
%   output Rout is a spatial referencing object. The world limits of Rout
%   are determined by forward mapping the world limits of Rin according to
%   tform. The ImageSize of Rout is determined by scaling Rin.ImageSize by
%   the scale factors in tform.

% Copyright 2012-2014 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(R_in,tform);

is2d = ~isa(R_in,'imref3d');
if is2d
    
    [XWorldLimitsOut,YWorldLimitsOut] = outputLimits(tform,R_in.XWorldLimits,R_in.YWorldLimits);
    
    R_out = images.spatialref.internal.snapWorldLimitsToSatisfyResolution([XWorldLimitsOut; YWorldLimitsOut],...
        [R_in.PixelExtentInWorldX, R_in.PixelExtentInWorldY]);
        
else
    
    [XWorldLimitsOut,YWorldLimitsOut,ZWorldLimitsOut] = outputLimits(tform,R_in.XWorldLimits,R_in.YWorldLimits,R_in.ZWorldLimits);

    R_out = images.spatialref.internal.snapWorldLimitsToSatisfyResolution([XWorldLimitsOut; YWorldLimitsOut; ZWorldLimitsOut],...
        [R_in.PixelExtentInWorldX, R_in.PixelExtentInWorldY, R_in.PixelExtentInWorldZ]);

end


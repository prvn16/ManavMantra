function tform = convertSpatialToHGTform(spatialDetails, sliceDim)

% Copyright 2016 The MathWorks, Inc.

sliceLoc = spatialDetails.PatientPositions;
allPixelSpacings = spatialDetails.PixelSpacings;

xSpacing = allPixelSpacings(1,1);
ySpacing = allPixelSpacings(1,2);
zSpacing = mean(diff(sliceLoc(:,sliceDim)));
spacings = abs([xSpacing,ySpacing,zSpacing]);
spacings = spacings ./ min(spacings);
tform = makehgtform('scale',spacings);

end
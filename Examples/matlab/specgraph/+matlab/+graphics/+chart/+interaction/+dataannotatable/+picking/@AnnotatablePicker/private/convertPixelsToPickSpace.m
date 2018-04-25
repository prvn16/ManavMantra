function viewerLocations = convertPixelsToPickSpace(hContext, pixelLocations)
%convertPixelsToPickSpace Covnert pixels to picking reference frame
%
%  convertPixelsToPickSpace(hContext, pixels) converts the given pixel
%  locations into the correct reference frame for picking.

%  Copyright 2013-2014 The MathWorks, Inc.

% The picking frame is currently the viewer's pixel reference frame, so
% not action is necessary.
viewerLocations = pixelLocations;

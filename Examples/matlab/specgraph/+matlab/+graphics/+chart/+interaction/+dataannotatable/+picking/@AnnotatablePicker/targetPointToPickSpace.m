function pickPoint = targetPointToPickSpace(obj, hContext, point, isPixel)
%targetPointToPickSpace Transform target into the picking coordinate system
%
%  targetPointToPickSpace(obj, hContext, point, isPixel) converts a target
%  point into a location in a reference frame suitable for picking.  If
%  isPixel is false, the input point is interpreted as a data location.  If
%  isPixel is trued, the input point is interpreted as a pixel location.
%  The returned point will be a (1x3) vector containing a X, Y and Z value.

%  Copyright 2013-2014 The MathWorks, Inc.

if isPixel
    pickPoint = convertPixelsToPickSpace(hContext, point(:)).';
else  
    % Assume point is a data location and project it into the viewer
    pointValid = obj.isValidInPickSpace(hContext, point);
    if pointValid
        % Request a 3D point.  Not all algorithms use this, but it is cheap to
        % produce for a single point.
        pickPoint = convertDataToPickSpace(hContext, point(:), true).';
    else
        pickPoint = [NaN NaN NaN];
    end
end

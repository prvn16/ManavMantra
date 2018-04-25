function out = inpoly(x, y, xp, yp)
% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.
%
% OUT = INPOLY(X, Y, XP, YP) determines points on point cloud located at X
% and Y that are within the polygon defined by XP and YP. OUT is a logical
% array indicating whether the corresponding x and y location in the point
% cloud is located within or on the polygon defined by XP and YP.
%
% This function is intended solely for use with polygon vertices generated
% by the impoly object. For polygons with more complicated definitions
% (e.g. loops, mulitply connected polygons), use inpolygon.
%
% Internal utility function for use with the Color Thresholder app
%
% Copyright 2016 The MathWorks, Inc.

supportedClasses = {'double'};
supportedAttributes = {'real','finite','nonempty'};

validateattributes(x,supportedClasses,supportedAttributes,mfilename,'X');
validateattributes(y,supportedClasses,supportedAttributes,mfilename,'Y');
validateattributes(xp,supportedClasses,supportedAttributes,mfilename,'XP');
validateattributes(yp,supportedClasses,supportedAttributes,mfilename,'YP');

if ~isvector(xp) || numel(xp) < 2
    error(message('images:validate:requireVectorInput'));
end

if ~isequal(size(x),size(y))
    error(message('images:validate:unequalSizeMatrices','x','y'));
end

if ~isequal(size(xp),size(yp))
    error(message('images:validate:unequalSizeMatrices','xp','yp'));
end

if numel(xp) == 2
    out = false(size(x(:)));
else
    % Pad end of polygon with starting vertex
    mp = length(xp);
    xp(mp+1) = xp(1);
    yp(mp+1) = yp(1);

    out = images.internal.inpolymex(x(:),y(:),xp(:),yp(:));
end

end
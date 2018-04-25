function [x,y,valid] = fixSelfIntersectingFaces(x,y,valid)
% This function is undocumented and may change in a future release.

% This function will look for places where the y-data flips (so the "top"
% of the Area flips below the "bottom" of the Area). When this occurs, we
% need to insert an extra vertex at the cross-over point so that the
% quadrilaterals are drawn correctly.
% 
% This function is currently used in two places:
% 1) createAreaVertexData (during Area's doUpdate)
% 2) patchVertexData (when saving Area objects)

%    Copyright 2016 The MathWorks, Inc.

% x is a column vector with the x-value for each set of y-values.
% y is a two-column matrix with the bottom (first column) and top (second
% column) of the Area for each x-value.

% Calculate flipped and unflipped separately in case of NaN values.
flipped = y(:,2) < y(:,1);
unflipped = y(:,1) < y(:,2);

% Find the index where flips occur.
% Make sure that NaN values are not counted as flips.
flips = find(...
    (flipped(1:end-1) & unflipped(2:end)) | ...
    (unflipped(1:end-1) & flipped(2:end)));

% Eliminate any flips that occur without the X-value changing.
differentX = x(flips)~=x(flips+1);
flips = flips(differentX);

% If no flips occur, no further action necessary.
if isempty(flips)
    return
end

% Calculate the intersection point for each flip.
d1 = y(flips,2)-y(flips,1); % Height of area before flip.
d2 = y(flips+1,2)-y(flips+1,1); % Height of area after flip.
t = d1./(d1-d2);
xIntersection = x(flips) + t.*(x(flips+1)-x(flips));
yIntersection = y(flips,1) + t.*(y(flips+1,1)-y(flips,1));

% Insert the intersection points into the original vectors.
[x,o] = sort([x; xIntersection]);
y = [y; [yIntersection yIntersection]];
y = y(o,:);

% Update the list of valid data points.
if nargin == 3
    valid = [valid; valid(flips)&valid(flips+1)];
    valid = valid(o);
end

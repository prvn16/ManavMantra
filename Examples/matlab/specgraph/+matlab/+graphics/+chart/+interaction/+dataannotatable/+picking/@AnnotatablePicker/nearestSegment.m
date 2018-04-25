function [index1, index2, t] = nearestSegment(obj, hContext, point, pointPixel, varargin)
%nearestSegmentToPixel Find the indices of the nearest line segment
%
%  [ind1, ind2, t] = nearestSegment(obj, hContext, point, pointPixel, data)
%  finds the line segment in the 2D or 3D data array that is closest to the
%  provided point. The data array should be of size (Nx2) or (Nx3) and the
%  point should be either a data point or a pixel point.  The type of
%  target is specified by setting pointPixel to true or false.  
%
%  The function returns the indices of the data points at each end of the
%  closest segment as well as the fraction along the line segment that is
%  closest to the given point. t will always be between 0 and 1.
% 
%  nearestSegment(obj, hContext, point, pointPixel, xdata, ydata, zdata)
%  performs the same operation on separate X, Y, and (optional) Z data
%  vectors.

%  Copyright 2013-2014 The MathWorks, Inc.

index1 = zeros(1,0);
index2 = zeros(1,0);
t = 0;
usabilityTolerance = 0.5; % Set a usability tolerance to decide if two segments have to be treated as overlapping

% Convert target to picking space
point = obj.targetPointToPickSpace(hContext, point, pointPixel);

% Filter out non-visible data
valid = obj.isValidInPickSpace(hContext, varargin{:});

if any(valid) && all(isfinite(point))
    % Split data into segments according to validity.
    steps = diff([false; valid(:); false]);
    sections = find(steps~=0);
    sections = reshape(sections, 2, numel(sections)/2);
    sections(2,:) = sections(2,:) - 1;
    
    % Transform valid data into pixel locations
    pixelLocations = obj.convertToPickSpace(hContext, varargin, valid);
    
    [index1, index2, t] = matlab.graphics.chart.interaction.dataannotatable.picking.nearestLineSegment(point, pixelLocations, sections, usabilityTolerance);
end

function index = nearestPoint(obj, hContext, point, pointPixel, varargin)
%nearestPoint Find the index of the nearest point
%
%  nearestPoint(obj, hContext, point, pointPixel, data) returns the index
%  of the point in the 2D or 3D data array that is visually closest to the
%  provided point. The data array should be of size (Nx2) or (Nx3) and the
%  point should be either a data point or a pixel point.  The type of
%  target is specified by setting pointPixel to true or false.
% 
%  nearestPoint(obj, hContext, point, pointPixel, xdata, ydata, zdata)
%  performs the same operation on separate X, Y, and (optional) Z data
%  vectors.
%
%  nearestPoint(..., metric) specifies a distance metric to use for the
%  comparison.  Valid options are 'euclidean', 'x' and 'y'.

%  Copyright 2013-2014 The MathWorks, Inc.

if ischar(varargin{end})
    % Use the specified metric
    metric = varargin{end};
    varargin(end) = [];
else
    % Default to euclidean measure
    metric = 'euclidean';
end

index = zeros(1,0);

% Convert target to picking space
point = obj.targetPointToPickSpace(hContext, point, pointPixel);

% Filter out non-visible data
valid = obj.isValidInPickSpace(hContext, varargin{:});

if any(valid) && all(isfinite(point))
    % Transform data into pixel locations
    pixelLocations = obj.convertToPickSpace(hContext, varargin, valid);
    
    index = matlab.graphics.chart.interaction.dataannotatable.picking.nearestPoint(point, pixelLocations, metric);
    
    if ~all(valid)
        % Map back to data index
        validInd = find(valid, index);
        index = validInd(index);
    end
end

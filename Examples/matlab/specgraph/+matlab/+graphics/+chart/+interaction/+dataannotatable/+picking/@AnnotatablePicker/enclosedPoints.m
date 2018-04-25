function ind = enclosedPoints(obj, hContext, polygon, varargin)
%enclosedPoints Find the indices of the enclosed points
%
%  enclosedPoints(obj, hContext, polygon, data) returns the indices of the
%  points in the 2D or 3D data array that are enclosed by the provided
%  polygon. The data array should be of size (Nx2) or (Nx3).  The polygon
%  should be a (2xN) array of pixel positions in the reference frame of the
%  viewer.
% 
%  enclosedPoints(obj, hContext, polygon, xdata, ydata, zdata) performs the
%  same operation on separate X, Y, and (optional) Z data vectors.

%  Copyright 2013-2014 The MathWorks, Inc.

ind = zeros(1,0);

% Filter out non-visible data
valid = obj.isValidInPickSpace(hContext, varargin{:});

if any(valid) && all(isfinite(polygon(:)))
    
    % Transform data into the picking space
    data = obj.convertToPickSpace(hContext, varargin, valid);
    polygon = convertPixelsToPickSpace(hContext, polygon);
    
    ind = matlab.graphics.chart.interaction.dataannotatable.picking.enclosedPoints(polygon, data);
     
    if ~isempty(ind) && ~all(valid)
        % Map back to data index
        validInd = find(valid, max(ind));
        ind = validInd(ind);
        
        % Ensure indices are a row vector
        if size(ind,1)>1
            ind = ind.';
        end
    end
end

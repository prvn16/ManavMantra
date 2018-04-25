function valid = isValidInPickSpace(obj, hContext, varargin)
%isValidInPickSpace Test whether data points are valid in the picking coordinate system
%
%  isValidInPickSpace(obj, hContext, data) tests whether data locations
%  have a valid representation in the reference frame that is used for
%  picking locations.  Data may be invalid if it is non-finite, or for
%  example is negative and in a positive-log scale.
%
%  isValidInPickSpace(obj, hContext, xdata, ydata, zdata) performs the same
%  operation on separate x, y, and z data vectors.

%  Copyright 2013-2015 The MathWorks, Inc.

[~, ~, ds, matBelow] = matlab.graphics.internal.getSpatialTransforms(hContext);
n = numel(varargin);
if n == 1
    iter = matlab.graphics.axis.dataspace.IndexPointsIterator( ...
        'Vertices', varargin{1});
elseif n == 2
    iter = matlab.graphics.axis.dataspace.XYZPointsIterator( ...
        'XData', varargin{1}, 'YData', varargin{2});
else
    iter = matlab.graphics.axis.dataspace.XYZPointsIterator( ...
        'XData', varargin{1}, 'YData', varargin{2}, 'ZData', varargin{3});
end
valid = ds.isTransformable(matBelow, iter);

function pickLocations = convertToPickSpace(obj, hContext, data, valid, request3D)
%convertToPickSpace Transform data into the picking coordinate system
%
%  convertToPickSpace(obj, hContext, data, isvalid, request3D) converts
%  data in the reference frame of the given object into an array of
%  locations in a reference frame suitable for picking.  The input data is
%  first indexed using the provided validity vector, resulting in an output
%  array of size (2xNumValid).  If the optional request3D flag is provided
%  and set to true, the output will have a size of (3xNumValid) with the
%  third row containing Z data.

%  Copyright 2013-2014 The MathWorks, Inc.

if nargin<5
    request3D = false;
end

% Create an iterator that matches the data
if numel(data)==1
    iter = matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices', data{1});
    if ~all(valid)
        iter.Indices = find(valid);
    end
else
    if ~all(valid)
        % Index out the valid values
        for n = 1:numel(data)
            data{n} = data{n}(valid);
        end
    end
    
    iter = matlab.graphics.axis.dataspace.XYZPointsIterator(...
        'XData', data{1}, 'YData', data{2}); 
    if numel(data)>2  && ~isempty(data{3})
        iter.ZData = data{3};
    end
end

% Transform data into pixel locations
pickLocations = convertDataToPickSpace(hContext, iter, request3D);

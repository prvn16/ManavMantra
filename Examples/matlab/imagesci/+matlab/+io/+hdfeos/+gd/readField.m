function [data,lat,lon] = readField(gridID,fieldName,start,count,stride)
%readField Read data from a grid field.
%   DATA = readField(gridID,FIELDNAME) reads the entire grid field 
%   identified by FIELDNAME in the grid identified by gridID.  
%
%   DATA = readField(gridID,FIELDNAME,START,COUNT) reads a contiguous
%   hyperslab of data from the field.    START specifies the zero-based
%   starting index of the hyperslab.  COUNT specifies the number of values
%   to read along each dimension.
%
%   DATA = readField(gridID,FIELDNAME,START,COUNT,STRIDE) reads a
%   strided hyperslab of data from the field.  STRIDE specifies the
%   inter-element spacing along each dimension.
%
%   [DATA,LAT,LON] = readField(...) reads the data and the associated 
%   geo-coordinates from the grid field.  This syntax is only allowed 
%   when the leading two dimensions of the grid are 'XDim' and 'YDim'.  
%
%   This function corresponds to the GDreadfield function in the HDF-EOS
%   library C API.
%
%   Example:  Read the data, latitude, and longitude for the 'ice_temp'
%   field.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [data,lat,lon] = gd.readField(gridID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   Example:  Read only the first 4x4 hyperslab of data, latitude, and 
%   longitude for the 'ice_temp' field.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [data2,lat2,lon2] = gd.readField(gridID,'ice_temp',[0 0], [4 4]);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%    See also gd, gd.writeField

%   Copyright 2010-2013 The MathWorks, Inc.

switch(nargin)
    case 2
        start = [];
        count = [];
        stride = [];
    case 4
        stride = [];
end

% Must reverse the start, count, and stride arguments because of 
% matlab-vs-C indexing.
fstart = fliplr(start);
fcount = fliplr(count);
fstride = fliplr(stride);


[data,status] = hdf('GD','readfield',gridID,fieldName,fstart,fstride,fcount);
hdfeos_gd_error(status,'GDreadfield');


if nargout > 1
    [dims,~,dimlist] = matlab.io.hdfeos.gd.fieldInfo(gridID,fieldName);
    if numel(dims) == 1
        error(message('MATLAB:imagesci:hdfeos:onlyOneReadFieldDimension', fieldName));
    end
    if ~(any(strcmp(dimlist,'XDim')) && any(strcmp(dimlist,'YDim')))
         error(message('MATLAB:imagesci:hdfeos:fieldNotLeadingXDimYDim', fieldName));       
    end
    
    % Locate XDim
    xpos = find(strcmp(dimlist,'XDim'));
    ypos = find(strcmp(dimlist,'YDim'));
    
    
    if isempty(start)
        start = zeros(1,numel(dims));
        count = dims;
    end
    if isempty(stride)
        stride = ones(1,numel(dims));
    end

    % the data might be multidimensional, so we need to get the index
    % arguments that correspond to XDim and YDim only.
    if ( ypos > xpos )
        start = start([xpos ypos]);
        stride = stride([xpos ypos]);
        count = count([xpos ypos]);
    else
        start = start([ypos xpos]);
        stride = stride([ypos xpos]);
        count = count([ypos xpos]);
    end
    
    r = start(1):stride(1):(start(1) + stride(1)*count(1)-1);
    c = start(2):stride(2):(start(2) + stride(2)*count(2)-1);
    [Col,Row] = meshgrid(c,r);
    [lat,lon] = matlab.io.hdfeos.gd.ij2ll(gridID,Row,Col);
end


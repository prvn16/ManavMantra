function writeData(sdsID,varargin)
%writeData Write to data set.
%   writeData(sdsID,DATA) writes all the data to the data set identified
%   by sdsID.
%
%   writeData(sdsID,START,DATA) writes a contiguous hyperslab to the
%   data set.  START specifies the zero-based starting index.  The number
%   of values along each dimension is inferred from the size of DATA.
%
%   writeData(sdsID,START,STRIDE,DATA) writes a strided hyperslab of
%   data to a grid datafield.  The number of elements to write along each
%   dimension is inferred either from the size of DATA or from the data set
%   itself.
%
%   START and STRIDE use zero-based indexing.
%
%   This function corresponds to the SDreadchunk function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   START and STRIDE parameters are reversed with respect to the C library 
%   API.
%
%   Example:  Write to a 2D data set.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       data = rand(10,20);
%       sd.writeData(sdsID,[0 0],data);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   Example:  Write to a 2D unlimited data set.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 0]);
%       data = rand(10,20);
%       sd.writeData(sdsID,[0 0],data);
%       data = rand(10,30);
%       sd.writeData(sdsID,[0 20],data);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%  
%    See also:  sd, sd.readData.

%   Copyright 2010-2013 The MathWorks, Inc.

narginchk(2,4);
[~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);

switch(nargin)
    case 2
        data = varargin{1};
        start = zeros(1,numel(dims));
        stride = ones(1,numel(dims));
        edge = dims;
        
    case 3
        start = varargin{1};
        stride = ones(1,numel(start));
        data = varargin{2};
        if (numel(dims) == 1)
            edge = numel(data);
        else
            edge = size(data);
        end
        
        
    case 4
        start = varargin{1};
        stride = varargin{2};
        data = varargin{3};
        if (numel(dims) == 1)
            edge = numel(data);
        else
            edge = size(data);
        end
        
end

if numel(start) > numel(edge)
    % We must be trying to write with an implied count of one along the
    % trailing dimension.
    edge = [edge ones(1,numel(start)-numel(edge))];
end

% Must flip dimensions.
start = fliplr(start);
stride = fliplr(stride);
edge = fliplr(edge);

status = hdf('SD','writedata',sdsID,start,stride,edge,data);
if status < 0
    hdf4_sd_error('SDwritedata');
end

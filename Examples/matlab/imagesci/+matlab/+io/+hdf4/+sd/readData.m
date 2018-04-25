function data = readData(sdsID,start,count,stride)
%readData Read subsample of data.
%   DATA = readData(sdsID) reads all of the data for the data set
%   identified by sdsID.
%
%   DATA = readData(sdsID,START,COUNT) reads a contiguous hyperslab of
%   data from the data set identified by sdsID.  START specifies the
%   starting position from where the hyperslab will be read. COUNT
%   specifies the number of values to be read along each data set
%   dimension.
%
%   DATA = readData(sdsID,START,COUNT,STRIDE) reads a strided hyperslab
%   of data from the data set identified by sdsID. 
%
%   START, COUNT, and STRIDE use zero-based indexing.
%
%   This function corresponds to the SDreaddata function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   START, COUNT, and STRIDE parameters are reversed with respect to the C 
%   library API.
%
%   Example:  Read an entire data set.
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       data = sd.readData(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   Example:  Read a 2x3 portion of a data set.  
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       data = sd.readData(sdsID,[0 0],[2 3]);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%    See also:  sd, sd.writeData.

%   Copyright 2010-2013 The MathWorks, Inc.


switch (nargin)
    case 1        
        [~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);
        start = zeros(1,numel(dims));
        stride = ones(1,numel(dims));
        count = dims;
        
    case 3
        stride = ones(1,numel(start));     
end

% Must reverse the start, count, and stride arguments because of 
% matlab-vs-C indexing.
start = fliplr(start);
count = fliplr(count);
stride = fliplr(stride);

[data,status] = hdf('SD','readdata',sdsID,start,stride,count);
if status < 0
    hdf4_sd_error('SDreaddata');
end



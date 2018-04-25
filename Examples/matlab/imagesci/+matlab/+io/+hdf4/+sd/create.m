function sdsID = create(sdID,name,datatype,dims)
%create Create a new data set.
%   sdsID = create(sdID,NAME,DATATYPE,DIMS) creates a data set with the
%   given name NAME, datatype DATATYPE, and dimension sizes DIMS.  
%
%   In order to create a data set with an unlimited dimension, the last
%   value in DIMS should be set to 0.
%
%   This function corresponds to the SDcreate function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   DIMS parameter is reversed with respect to the C library API.
%
%   Example:  Create a 3D data set with an unlimited dimension.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20 0]);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.endAccess.

%   Copyright 2010-2013 The MathWorks, Inc.

switch(datatype)
    case 'double'
        datatype = 'float64';
    case 'single'
        datatype = 'float32';
end
dims = fliplr(dims);
sdsID = hdf('SD','create',sdID,name,datatype,numel(dims),dims);
if sdsID < 0
    hdf4_sd_error('SDcreate');
end

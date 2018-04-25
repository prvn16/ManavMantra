function varlist = nameToIndices(sdID,name)
%nameToIndices Retrieve list of data sets with same name.
%   VARSTRUCT = nameToIndices(sdID,SDSNAME) returns a struct array for all
%   data sets with the same name.  Each element of VARSTRUCT has two
%   fields:
%
%       'index' - index of data set
%       'type   - type of data set, either 'SDSVAR', 'COORDVAR', or
%                'UNKNOWN'
%
%   This function corresponds to the SDnametoindices function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       varlist = sd.nameToIndices(sdID,'latitude');
%       sd.close(sdID);
%
%   See also sd, sd.setDimScale, sd.isCoordVar.

%   Copyright 2010-2013 The MathWorks, Inc.

varlist = hdf('SD','nametoindices',sdID,name);

function objType = idType(objID)
%idType Return type of object.
%   OBJTYPE = idType(objID) returns the type of object that objID
%   represents.  Possible values for OBJTYPE are
%
%       'NOT_SDAPI_ID' - the object is not an HDF SD identifier
%       'SD_ID'        - the object if an SD identifier (file handle)
%       'SDS_ID'       - the object is a data set identifier
%       'DIM_ID'       - the object is a dimension identifier
%
%   This function corresponds to the SDidtype function in the HDF library C
%   API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       objType = sd.idType(sdID);
%       sd.close(sdID);
%
%   See also sd.

%   Copyright 2010-2013 The MathWorks, Inc.

objType = hdf('SD','idtype',objID);

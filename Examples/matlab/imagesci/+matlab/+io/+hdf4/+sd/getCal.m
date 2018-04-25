function [cal,calErr,offset,offsetErr,datatype] = getCal(sdsID)
%getCal Retrieve data set calibration information.
%   [CAL,CALERR,OFFSET,OFFSETERR,DATATYPE] = getCal(sdsID) retrieves the
%   calibration information associated with a data set.
%
%   This function corresponds to the SDgetcal function in the HDF library C
%   API.
%
%   Example: .
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       [cal,calErr,offset,offsetErr,dtype] = sd.getCal(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setCal.

%   Copyright 2010-2013 The MathWorks, Inc.

[cal,calErr,offset,offsetErr,datatype,status] = hdf('SD','getcal',sdsID);
if status < 0
    hdf4_sd_error('SDgetcal');
end

function setExternalFile(sdsID,filename,offset)
%setExternalFile Store data in an external file.
%   setExternalFile(sdsID,EXTFILE,OFFSET) moves data values (not
%   metadata) into the external data file EXTFILE starting at the byte
%   offset OFFSET.
%
%   Data can only be moved once for any given data set.  The external file
%   should be kept with the main file.
%
%   This function corresponds to the SDsetexternalfile function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       sd.setExternalFile(sdsID,'myExternalFile.dat',0);
%       sd.writeData(sdsID,[0 0],rand(10,20));
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.create, sd.writeData.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','setexternalfile',sdsID,filename,offset);
if status < 0
    hdf4_sd_error('SDsetexternalfile');
end

function prevMode = setFillMode(sdID,fillMode)
%setFillMode Set the current fill mode of a file.
%   PREVMODE = setFillMode(sdID,FILLMODE) returns the previous fill mode
%   of a file and resets it to FILLMODE.  This setting applies to all data
%   sets contained in the file identified by sdID.
%
%   Possible values of FILLMODE are 'fill', and 'nofill'.  'fill' is the
%   default mode and indicates that fill values will be written when the
%   data set is created.  'nofill' indicates that the fill values will not
%   be written.
%
%   When a fixed-size data set is created, the first call to sd.writeData 
%   will fill the entire data set with the default or user-defined fill 
%   value if FILLMODE is 'fill'.  In data sets with an unlimited dimension,
%   if a new write operation takes place along the unlimited dimension
%   beyond the last location of the previous write operation, the array
%   locations between these written areas will be initialized to the
%   user-defined fill value, or the default fill value if a user-defined
%   fill value has not been specified.
%
%   If it is certain that all data set values will be written before any
%   read operation takes place, there is no need to write the fill values.
%   Calling sd.setFillMode with 'nofill' can improve performance in this
%   case.
%
%   This function corresponds to the SDsetfillmode function in the HDF
%   library C API.
%
%   Example:  Write two partial records.  The first will be written in
%   'nofill' mode, but the 2nd with 'fill' mode.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sd.setFillMode(sdID,'nofill');
%       sdsID = sd.create(sdID,'temperature','double',[10 10 0]);
%       sd.writeData(sdsID,[0 0 0], rand(5,5));
%       sd.setFillMode(sdID,'fill');
%       sd.setFillValue(sdsID,-999);
%       sd.writeData(sdsID,[0 0 1], rand(5,5));
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setFillValue, sd.getFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.


fillMode = lower(fillMode);

prevMode = hdf('SD','setfillmode',sdID,fillMode);
if prevMode < 0
    hdf4_sd_error('SDsetfillmode');
end
if prevMode == 0
    prevMode = 'fill';
else
    prevMode = 'nofill';
end

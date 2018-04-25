function setRange(sdsID,maxval,minval)
%setRange Set maximum and minimum range value for data set.
%   setRange(sdsID,MAXVAL,MINVAL) sets the maximum and minimum range
%   values of the data set identified by sdsID.  These values form the
%   "valid_range" attribute for sdsID.
%
%   The actual maximum and minimum values of the data set are not computed.
%   The "valid_range" attribute is for informational purposes only.
%
%   This function corresponds to the SDsetrange function in the HDF library
%   C interface.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       sd.setDataStrs(sdsID,'Temperature','degrees_celsius','%.2f','');
%       sd.setRange(sdsID,1000,-273.15);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getRange.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(minval,{'numeric'},{'scalar'},'','MINVAL');
validateattributes(maxval,{'numeric'},{'scalar','>=',minval},'','MAXVAL');

status = hdf('SD','setrange',sdsID,maxval,minval);
if status < 0
    hdf4_sd_error('SDsetrange');
end

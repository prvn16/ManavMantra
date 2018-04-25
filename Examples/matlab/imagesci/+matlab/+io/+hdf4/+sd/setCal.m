function setCal(sdsID,cal,calErr,offset,offsetErr,datatype)
%setCal Set data set calibration information.
%   setCal(sdsID,CAL,CALERR,OFFSET,OFFSETERR,DATATYPE) sets the 
%   calibration information for with a data set.
%
%   This function corresponds to the SDsetcal function in the HDF library
%   C API.
%
%   Example: .
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       sd.setDataStrs(sdsID,'Temperature','degrees_kelvin','%.3f','spherical');
%       sd.setCal(sdsID,1,0,273,0,'double');
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getCal.

%   Copyright 2010-2013 The MathWorks, Inc.


validateattributes(cal,{'numeric'},{'scalar'},'','CAL');
validateattributes(calErr,{'numeric'},{'scalar'},'','CALERR');
validateattributes(offset,{'numeric'},{'scalar'},'','OFFSET');
validateattributes(offsetErr,{'numeric'},{'scalar'},'','OFFSETERR');

status = hdf('SD','setcal',sdsID,cal,calErr,offset,offsetErr,datatype);
if status < 0
    hdf4_sd_error('SDsetcal');
end

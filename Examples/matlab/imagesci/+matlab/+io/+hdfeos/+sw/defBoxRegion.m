function regionID = defBoxRegion(swathID,cornerlat,cornerlon,mode)
%defBoxRegion Define latitude-longitude region for swath.
%   regionID = defBoxRegion(swathID,LAT,LON,MODE) defines a
%   latitude-longitude box region for a swath.  LAT and LON are
%   two-element arrays containing the latitude and longitude in decimal
%   degrees of the box corners.    A cross track is determined to be within 
%   the box if a condition is met according to the value of MODE.
% 
%       'MIDPOINT' - the cross track midpoint is within the box
%       'ENDPOINT' - either endpoint is within the box
%       'ANYPOINT' - any point of the cross track is within the box
%
%   All elements of a cross track are within the region if the condition is
%   met.  The swath must have both Longitude and Latitude (or Colatitude)
%   defined.
%
%   REGIONID is an identifier to be used by sw.extractRegion to read all 
%   the entries of a data field within the region. 
%
%   This function corresponds to the SWdefboxregion and SWregionindex 
%   functions in the HDF-EOS library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       lat = [34 44];
%       lon = [16 24];
%       regionID = sw.defBoxRegion(swathID,lat,lon,'MIDPOINT');
%       data = sw.extractRegion(swathID,regionID,'Temperature');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.extractRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

switch(upper(mode))
    case 'MIDPOINT'
        mode = 'HDFE_MIDPOINT';
    case 'ENDPOINT'
        mode = 'HDFE_ENDPOINT';
    case 'ANYPOINT'
        mode = 'HDFE_ANYPOINT';
end
regionID = hdf('SW','defboxregion',swathID,cornerlon,cornerlat,mode);
hdfeos_sw_error(regionID,'SWdefboxregion');

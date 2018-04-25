function data = extractRegion(swathID,regionID,fieldName)
%extractRegion Read subsetted region.
%   DATA = extractRegion(swathID,REGIONID,FIELDNAME) reads data for a 
%   specified field from a subsetted region identified by REGIONID.
%
%   This function corresponds to the SWextractregion function in the
%   HDF-EOS library C API.
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
%   See also sw, sw.defBoxRegion, sw.defVrtRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

[data, status] = hdf('SW','extractregion',swathID,regionID,fieldName,'HDFE_INTERNAL');
hdfeos_sw_error(status,'SWextractregion');

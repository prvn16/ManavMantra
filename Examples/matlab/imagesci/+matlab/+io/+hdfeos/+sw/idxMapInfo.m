function idx = idxMapInfo(swathID,geodim,datadim)
%idxMapInfo Retrieve indexed array of geolocation mapping.
%   IDX = idxMapInfo(swathID,GEODIM,DATADIM) retrieves the indexed elements 
%   of the geolocation mapping between GEODIM and DATADIM.
%
%   This function corresponds to the SWidxmapinfo function in the HDF-EOS C
%   library API.
%
%   See also sw, sw.geoMapInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

[idxsize, idx] = hdf('SW','idxmapinfo',swathID,geodim,datadim);
hdfeos_sw_error(idxsize,'SWidxmapinfo');

idx = idx';

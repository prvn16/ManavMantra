function mappingType = geoMapInfo(swathID,dimname)
%geoMapInfo Retrieve type of dimension mapping for named dimension.
%   mappingType = geoMapInfo(swathID,DIMNAME) returns the type of dimension 
%   mapping for the named dimension.  mappingType will be one of 'indexed', 
%   'regular', or 'unmapped'.
%
%   This routine corresponds to the SWgeomapinfo function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       maptype = sw.geoMapInfo(swathID,'GeoTrack');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defDimMap.

%   Copyright 2010-2013 The MathWorks, Inc.

try
    dimlen = matlab.io.hdfeos.sw.dimInfo(swathID,dimname); %#ok<NASGU>
catch me
    error(message('MATLAB:imagesci:hdfeos:invalidGeoMapDimension', dimname));
end

type = hdf('SW','geomapinfo',swathID,dimname);
switch(type)
    case -1
        hdfeos_sw_error(type,'SWgeomapinfo');
    case 0
        mappingType = 'unmapped';
    case 1
        mappingType = 'regular';
    case 2
        mappingType = 'indexed';
    otherwise
        error(message('MATLAB:imagesci:hdfeos:unhandledGeoMappingType', type));
end

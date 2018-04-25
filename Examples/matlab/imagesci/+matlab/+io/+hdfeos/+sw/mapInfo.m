function [offset,increment] = mapInfo(swathID,geodim,datadim)
%mapInfo Retrieve offset and increment of specific geolocation mapping.
%   [OFFSET,INCREMENT] = mapInfo(swathID,GEODIM,DATADIM) retrieves the
%   offset and increment of the geolocation mapping between the specified
%   geolocation dimension and the specified data dimension.
%
%   This function corresponds to the SWmapinfo function in the HDF-EOS C
%   library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'GeoTrack',2000);
%       sw.defDim(swathID,'GeoXtrack',1000);
%       sw.defDim(swathID,'DataTrack',4000);
%       sw.defDim(swathID,'DataXtrack',2000);
%       sw.defDimMap(swathID,'GeoTrack','DataTrack',0,2);
%       sw.defDimMap(swathID,'GeoXtrack','DataXtrack',1,2);
%       sw.detach(swathID);
%       sw.close(swfid);
%       swfid = sw.open('myfile.hdf','read');
%       swathID = sw.attach(swfid,'MySwath');
%       [offset,increment] = sw.mapInfo(swathID,'GeoTrack','DataTrack');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defDimMap.

%   Copyright 2010-2013 The MathWorks, Inc.

[offset, increment, status] = hdf('SW','mapinfo',swathID,geodim,datadim);
hdfeos_sw_error(status,'SWmapinfo');

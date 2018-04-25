function [map,offset,increment] = inqMaps(swathID)
%inqMaps  Retrieve information about swath geolocation relations.
%   [MAP,OFFSET,INCREMENT] = inqMaps(swathID) returns the dimension
%   mapping list, the offset of each geolocation relation, and the
%   increment of each geolocation relation.  These mappings are not
%   indexed.  MAP is a cell array where each element contains the names of
%   the dimensions for each mapping, separated by a slash.  OFFSET and
%   INCREMENT contain the offset and increment of each geolocation
%   relation.
%
%   This function corresponds to the SWinqmaps routine in the HDF-EOS 
%   library.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [dimmap,offset,increment] = sw.inqMaps(swathID);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.inqDims, sw.defDimMap, sw.inqIdxMaps.

%   Copyright 2010-2015 The MathWorks, Inc.

try
    matlab.io.hdfeos.sw.inqDims(swathID);
catch me
    error(message('MATLAB:imagesci:hdfeos:invalidSwathID'));
end

[nmaps,rdimmap,offset,increment] = hdf('SW','inqmaps',swathID);
hdfeos_sw_error(nmaps,'SWinqmaps');

if nmaps == 0
    map = {};
    offset = [];
    increment = [];
else
    map = regexp(rdimmap,',','split');
    map = map';
end


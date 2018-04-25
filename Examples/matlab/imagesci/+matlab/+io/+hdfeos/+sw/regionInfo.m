function [ntype,dims] = regionInfo(swathID,regionID,fieldName)
%regionInfo Retrieve information about subsetted region.
%   [DATATYPE,EXTENT] = regionInfo(swathID,regionID,FIELDNAME) returns the
%   datatype and extent of a subsetted region of a field.  regionID is the 
%   identifier for the subsetted region.
%
%   This function corresponds to the SWregioninfo function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   EXTENT parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       lat = [34 44];
%       lon = [16 24];
%       regionID = sw.defBoxRegion(swathID,lat,lon,'MIDPOINT');
%       [ntype,dims] = sw.regionInfo(swathID,regionID,'Temperature');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defBoxRegion, sw.defVrtRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

[ntype,~,dims,~,status] = hdf('SW','regioninfo',swathID,regionID,fieldName);
hdfeos_sw_error(status,'SWregioninfo');

switch(ntype)
    case 'float'
        ntype = 'single';
    case 'float64'
        ntype = 'double';
end
% Flip due to majority issue.
dims = fliplr(dims);

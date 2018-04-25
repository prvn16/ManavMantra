function dimlen = dimInfo(swathID,dimname)
%dimInfo Retrieve size of dimension.
%   DIMLEN = dimInfo(swathID,DIMNAME) retrieves the length of the specified 
%   dimension.
%
%   This function corresponds to the SWdiminfo function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       dimlen = sw.dimInfo(swathID,'GeoTrack');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defDim.

%   Copyright 2010-2013 The MathWorks, Inc.

dimlen = hdf('SW','diminfo',swathID,dimname);
hdfeos_sw_error(dimlen,'SWdiminfo');

function regionID2 = defVrtRegion(swathID,regionID,vertObj,range)
%defVrtRegion Subset on a monotonic field or dimension.
%   REGIONID_OUT = defVrtRegion(swathID,regionID,VERTOBJ,RANGE) subsets on 
%   a monotonic field or contiguous elements of a dimension.  Whereas 
%   defBoxRegion and defTimePeriod subset along the 'Track' dimension, this 
%   routine allos the user to subset along any dimension.  regionID 
%   specifies the subsetted region from a previous call.  VERTOBJ specifies 
%   the dimension by which to subset.  RANGE specifies the minimum and 
%   maximum values for VERTOBJ.
%
%   If there is no current subsetted region, regionID should be
%   'noprevsub'.
%
%   VERTOBJ may be either a dimension or a field.  If it is a dimension,
%   then RANGE whould consist of dimension indices.  If VERTOBJ corresponds
%   to a field, then RANGE should consist of the minimum and maximum field
%   values.  VERTOBJ must be one-dimensional in this case, and the its
%   values must be monotonic.
%
%   This function corresponds to the SWdefvrtregion function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       regionID = sw.defVrtRegion(swathID,'noprevsub','Bands',[450 600]);
%       data = sw.extractRegion(swathID,regionID,'Spectra');
%       sw.detach(swathID);
%       sw.close(swfid);    
%
%   See also sw, sw.defBoxRegion, sw.defTimePeriod.

%   Copyright 2010-2013 The MathWorks, Inc.

if isnumeric(regionID) && (regionID == -1)
    regionID = 'noprevsub';
end
regionID2 = hdf('SW','defvrtregion',swathID,regionID,vertObj,range);
hdfeos_sw_error(regionID2,'SWdefvrtregion');

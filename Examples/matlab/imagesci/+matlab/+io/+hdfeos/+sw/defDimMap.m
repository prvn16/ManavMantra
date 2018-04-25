function defDimMap(swathID,geodim,datadim,offset,increment)
%defDimMap Define mapping between geolocation and data dimensions.
%   defDimMap(SWATHID,geoDim,dataDim,offset,increment) defines a
%   monotonic mapping between the geolocation and data dimensions, which
%   usually have differing lengths.  OFFSET gives the index of the data
%   element corresponding to the first geolocation element, and INCREMENT
%   gives the number of data elements to skip for each geolocation 
%   element.  If the geolocation dimension begins "before" the data 
%   dimension, then OFFSET is negative.  Similarly, if the geolocation
%   dimension has higher resolution than the data dimension, then INCREMENT
%   is negative.
%  
%   This function corresponds to the SWdefdimmap function in the HDF-EOS 
%   library.
%
%   Example:  Create a dimension mapping such that the first element of the
%   GeoTrack dimension corresponds to the first element of the DataTrack
%   Dimension and such that the data dimension has twice the resolution as
%   the geolocation dimension.  Also create a dimension mapping such that
%   the first element of the GeoXtrack dimension corresponds to the second
%   element of the DataXtrack dimensions and such that the data dimension 
%   has twice the resolution as the geolocation dimension.
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
%
%   See also sw, sw.defDim, sw.mapInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(offset,{'double'},{'scalar'},'','OFFSET');
validateattributes(increment,{'double'},{'scalar'},'','INCREMENT');

% Has a map already been defined?
try
    matlab.io.hdfeos.sw.mapInfo(swathID,geodim,datadim);
    error(message('MATLAB:imagesci:hdfeos:mapAlreadyDefined', geodim, datadim));
catch me
    if ~strcmp(me.identifier,'MATLAB:imagesci:hdfeos:hdfEosLibraryError')
        rethrow(me)
    end
end

status = hdf('SW','defdimmap',swathID,geodim,datadim,offset,increment);
hdfeos_sw_error(status,'SWdefdimmap');

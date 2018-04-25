function nents = nEntries(swathID,entType)
%nEntries Return number of entries for specific type.
%   NENTS = nentries(swathID,TYPE) returns the number of entries in a
%   swath.  Valid inputs for TYPE include
%
%       'dims'       or 'HDFE_NENTDIM'
%       'maps'       or 'HDFE_NENTMAP'
%       'imaps'      or 'HDFE_NENTIMAP'
%       'geofields'  or 'HDFE_NENTGFLD'
%       'datafields' or 'HDFE_NENTFLD'
%
%   This function corresponds to the SWnentries function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'GeoTrack',2000);
%       sw.defDim(swathID,'GeoXtrack',1000);
%       sw.defDim(swathID,'DataTrack',4000);
%       sw.defDim(swathID,'DataXtrack',2000);
%       ndims = sw.nEntries(swathID,'dims');
%       sw.detach(swathID);
%       sw.close(swfid);
%       
%   See also sw.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(entType)
    switch(entType)
        case 'dims'
            entType = 'NENTDIM';
        case 'maps'
            entType = 'NENTMAP';
        case 'imaps'
            entType = 'NENTIMAP';
        case 'geofields'
            entType = 'NENTGFLD';
        case 'datafields'
            entType = 'NENTDFLD';
    end
end
nents = hdf('SW','nentries',swathID,entType);
hdfeos_sw_error(nents,'SWnetries');

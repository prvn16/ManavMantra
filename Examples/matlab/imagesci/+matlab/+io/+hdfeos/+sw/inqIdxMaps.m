function [idxmap,idxsize] = inqIdxMaps(swathID)
%inqIdxMaps  Return information about swath indexed geolocation mapping.
%   [IDXMAP,IDXSIZE] = inqIdxMaps(swathID) retrieves all indexed
%   geolocation/data mappings defined in the swath.  IDXMAP will be a cell
%   array with each element consisting of the names of the dimensions of a
%   mapping, separated by a '/'.  IDXSIZE will contain the size of the
%   index arrays corresponding to each mapping.
%
%   This function corresponds to the SWinqidxmaps routine in the HDF-EOS 
%   library.
%
%   See also sw, sw.inqMaps.

%   Copyright 2010-2013 The MathWorks, Inc.

[nidxmaps,ridxmap,idxsize] = hdf('SW','inqidxmaps',swathID);
hdfeos_sw_error(nidxmaps,'SWinqidxmaps');

if nidxmaps == 0
    idxmap = {};
    idxsize = [];
else
    idxmap = regexp(ridxmap,',','split');
    idxmap = idxmap';
end


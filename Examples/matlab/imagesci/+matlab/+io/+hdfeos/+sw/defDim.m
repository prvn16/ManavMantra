function defDim(swathID,dimname,dimlen)
%defDim Define new dimension within swath.
%   defDim(swathID,DIMNAME,DIMLEN) defines a new dimension named DIMNAME
%   with length DIMLEN in the swath structure identified by swathID.
%
%   To specify an unlimited dimension, you may use either 0 or 'unlimited' 
%   for DIMLEN.
%  
%   This function corresponds to the SWdefdim function in the HDF-EOS 
%   library.
%
%   Example:  Define a dimension 'Band' with length of 15 and an unlimited
%   dimension 'Time'.
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'GeoTrack',2000);
%       sw.defDim(swathID,'GeoXtrack',1000);
%       sw.defDim(swathID,'DataTrack',4000);
%       sw.defDim(swathID,'DataXtrack',2000);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.dimInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(dimlen) && strcmp(dimlen,'unlimited')
	dimlen = 0;
end
status = hdf('SW','defdim',swathID,dimname,dimlen);
hdfeos_sw_error(status,'SWdefdim');

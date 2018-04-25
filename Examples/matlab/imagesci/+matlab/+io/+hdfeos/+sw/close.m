function close(swfid)
%close Close HDF-EOS swath file
%   close(swfid) closes an HDF-EOS swath file identified by swfid.
%
%   This function corresponds to the SWclose function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'ExampleSwath');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.open, sw.create.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SW','close',swfid);
hdfeos_sw_error(status,'SWclose');

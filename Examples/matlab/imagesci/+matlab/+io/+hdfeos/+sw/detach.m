function detach(swathID)
%detach Detach from swath.
%   detach(SWATHID) detaches from the swath identified by SWATHID.
%
%   This function corresponds to the SWdetach function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.attach, sw.create.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SW','detach',swathID);
hdfeos_sw_error(status,'SWdetach');

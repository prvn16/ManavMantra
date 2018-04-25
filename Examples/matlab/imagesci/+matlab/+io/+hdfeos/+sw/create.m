function swathID = create(swfid,swathname)
%create Create new swath structure.
%   swathID = create(swfid,SWATHNAME) creates a new swath structure
%   where swfid is the swath file identifier and SWATHNAME is the name of
%   the new swath.  The swath is created as a Vgroup with the HDF file with
%   the name SWATHNAME and HDF vgroup class 'SWATH'.
%
%   This function corresponds to the SWcreate function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'ExampleSwath');
%       sw.detach(swathID);
%       sw.close(swfid);
%       
%   See also sw, sw.detach.

%   Copyright 2010-2013 The MathWorks, Inc.


swathID = hdf('SW','create',swfid,swathname);
hdfeos_sw_error(swathID,'SWcreate');
